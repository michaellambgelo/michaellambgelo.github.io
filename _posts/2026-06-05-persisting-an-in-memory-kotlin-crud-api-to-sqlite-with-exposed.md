---
layout: post
title: "Persisting an in-memory Kotlin CRUD API to SQLite with Exposed"
date: 2026-06-05
category: software
image: "/seo/2026-06-05-persisting-an-in-memory-kotlin-crud-api-to-sqlite-with-exposed.png"
tags:
- kotlin
- ktor
- sqlite
- exposed
- homelab
published: true
---

A few weeks ago I [wrote about `kotlin-tutorial`]({{ site.url }}/2026/05/kotlin-tutorial-pedagogy-and-blog-widgets/), the small Ktor service on `node5` of my homelab that teaches Kotlin features through deliberately-duplicated routes and feeds the live widgets on my `/now` and `/cluster` pages. In that post I described a `/notes` CRUD module and said, plainly, that its data "resets on restart, on purpose" — that "persistence is a distraction" from the Ktor request/response idioms the module is there to teach.

That line was right about the handlers and incomplete about everything else. The Ktor idioms are still the whole lesson in the *handlers* — but "how do you give a repository a real backing store without disturbing the handlers" is a lesson in its own right, and a more interesting one than a `MutableMap` that quietly forgets everything every deploy. In-memory storage is a fine way to show the *shape* of a CRUD handler; the moment you want those notes to survive a restart — or to be shared by more than one caller — you need somewhere real to put them. So I added SQLite-on-disk persistence to `/notes`, backed by [JetBrains Exposed](https://github.com/JetBrains/Exposed), and the interesting part is how *little* of the app had to change to do it.

## The seam that made this easy

Here's the entire in-memory repository I started with:

```kotlin
class NoteRepository {
    private val store = ConcurrentHashMap<UUID, Note>()

    fun list(): List<Note> = store.values.sortedByDescending { it.createdAt }
    fun get(id: UUID): Note? = store[id]

    fun create(req: CreateNoteRequest): Note {
        val note = Note(UUID.randomUUID(), req.title, req.body, Instant.now())
        store[note.id] = note
        return note
    }

    fun update(id: UUID, req: UpdateNoteRequest): Note? { /* copy + put */ }
    fun delete(id: UUID): Boolean = store.remove(id) != null
}
```

The route handlers never touch the map directly. They call `repo.list()`, `repo.get(id)`, `repo.create(req)` and so on, and the repository is handed to them by a single line in `Routing.kt`:

```kotlin
val noteRepository = NoteRepository()
```

That one construction site is the whole seam. If I can keep `NoteRepository`'s public method names and shapes identical while swapping the `ConcurrentHashMap` for a database, then `NoteRoutes.kt` — the file that's actually teaching Ktor — never has to change. That's the goal the entire change is organized around: **the persistence is a new lesson in new files, not a rewrite of the existing one.**

## Picking the tools

Two dependencies. Exposed for the SQL DSL, and the Xerial JDBC driver for SQLite:

```kotlin
implementation("org.jetbrains.exposed:exposed-core:0.61.0")
implementation("org.jetbrains.exposed:exposed-jdbc:0.61.0")
implementation("org.xerial:sqlite-jdbc:3.50.1.0")
```

Exposed has two flavors: a DAO layer (entities with lifecycle, à la an ORM) and a typed SQL DSL. I used the **DSL**, not the DAO. In a teaching codebase the explicit `insert { }` / `selectAll().where { }` calls read like the SQL they generate, and I map rows to my existing `Note` data class by hand so the `Note` type — and its Jackson JSON serialization, and the OpenAPI schema generated from it — stays completely untouched. No DAO entity standing in for my domain type.

One detail that matters because `node5` is a Raspberry Pi: the `sqlite-jdbc` jar ships the native SQLite library for a pile of platforms baked into the artifact. I confirmed `Linux/aarch64/libsqlitejdbc.so` was actually in there before trusting it on arm64:

```text
$ unzip -l sqlite-jdbc-3.50.1.0.jar | grep aarch64
  org/sqlite/native/Linux/aarch64/libsqlitejdbc.so
  org/sqlite/native/Mac/aarch64/libsqlitejdbc.dylib
```

Linux arm64 for the Pi matches the arm64 node0 build host. I will not cover building container images in this post, but this is a similar process I followed [when I first deployed a Spring Boot app]({{ % site.url }} /2022/03/buildx-spring-boot/) on the cluster. 

## The table

A SQLite-backed Exposed table is an `object`:

```kotlin
object NotesTable : Table("notes") {
    val id = uuid("id")
    val title = text("title")
    val body = text("body")
    val createdAt = long("created_at")

    override val primaryKey = PrimaryKey(id)
}
```

That `createdAt = long(...)` is doing something deliberate, and getting there cost me an hour. Read on.

## Two gotchas SQLite hands you

I wrote the connection helper the obvious way the first time, and SQLite rejected it twice for two unrelated reasons. Both are worth knowing.

**Gotcha one: `PRAGMA journal_mode=WAL` cannot run inside a transaction.** I wanted Write-Ahead Logging (so readers don't block the single writer) and a busy-timeout (so a momentarily-locked database waits instead of throwing). My first instinct was to `exec()` those pragmas at startup — but Exposed wraps every `exec()` in a transaction, and SQLite refuses to switch journal modes from within one:

```text
[SQLITE_ERROR] cannot change into wal mode from within a transaction
```

The fix is to set those options on the `DataSource` instead, where they're applied in autocommit as each connection opens:

```kotlin
object NotesDatabase {
    private const val DEFAULT_PATH = "build/notes.db"

    fun connect(path: String = resolvePath()): Database {
        File(path).absoluteFile.parentFile?.mkdirs()
        val dataSource = SQLiteDataSource(
            SQLiteConfig().apply {
                setJournalMode(SQLiteConfig.JournalMode.WAL)
                setBusyTimeout(5000)
            },
        ).apply { url = "jdbc:sqlite:$path" }

        val db = Database.connect(dataSource)
        transaction(db) { SchemaUtils.create(NotesTable) }
        return db
    }

    private fun resolvePath(): String =
        System.getProperty("notes.db.path")
            ?: System.getenv("NOTES_DB_PATH")?.takeIf { it.isNotBlank() }
            ?: DEFAULT_PATH
}
```

(The path resolution there — system property, then environment variable, then a gitignored `build/notes.db` default — is what lets the container point at a mounted volume and lets each test point at its own throwaway file. More on both below.)

**Gotcha two: the timestamp came back five hours late.** Exposed has a `timestamp()` column type from its `exposed-java-time` module that maps straight to `java.time.Instant`, and that's what I reached for first. The CRUD smoke test caught it immediately. I POSTed a note and the response said it was created at `06:18:23Z`. I read the same note back out of the database and it claimed `11:18:23Z` — the same note, five hours apart:

```text
POST response:  "createdAt": "2026-06-05T06:18:23Z"
GET (from DB):  "createdAt": "2026-06-05T11:18:23Z"
```

An `Instant` is an absolute point on the timeline. Serializing the *same* instant twice should never produce two different strings. Five hours is exactly my UTC offset (CDT), which is the tell: somewhere in the round-trip, a local-vs-UTC conversion was being applied on the way out but not on the way in. SQLite has no native timestamp type, so that column type stores the value as text and re-anchors it through the JVM's default zone — and on SQLite that round-trip isn't symmetric.

I didn't want to fight a column type's timezone assumptions in a *teaching* repo, where the storage format should be something a reader can reason about at a glance. So I dropped `exposed-java-time` entirely and stored the timestamp as **epoch milliseconds in a plain `long`**:

```kotlin
// write
it[createdAt] = note.createdAt.toEpochMilli()
// read
createdAt = Instant.ofEpochMilli(this[NotesTable.createdAt])
```

Epoch millis has no timezone to get wrong, and it sorts chronologically *as a number* — which matters, because the list endpoint orders by `created_at DESC`. (A tempting alternative, storing ISO-8601 text, would have sorted wrong: `Instant.toString()` emits variable-width fractional seconds, so `...:23Z` sorts *after* `...:23.310Z` lexicographically even though it's earlier in time.) I also truncate to millis at creation, so the value the POST returns is byte-for-byte the value a later GET returns.

This is the part I'd have skipped if `/notes` were "just a demo." It's also the most useful thing in the post, so I'm glad it broke.

## The repository, rewritten

Same public surface, new insides. Two things change beyond "talk to SQL":

```kotlin
class NoteRepository(private val db: Database) {

    private fun ResultRow.toNote() = Note(
        id = this[NotesTable.id],
        title = this[NotesTable.title],
        body = this[NotesTable.body],
        createdAt = Instant.ofEpochMilli(this[NotesTable.createdAt]),
    )

    suspend fun list(): List<Note> = newSuspendedTransaction(Dispatchers.IO, db) {
        NotesTable.selectAll()
            .orderBy(NotesTable.createdAt to SortOrder.DESC)
            .map { it.toNote() }
    }

    suspend fun get(id: UUID): Note? = newSuspendedTransaction(Dispatchers.IO, db) {
        NotesTable.selectAll().where { NotesTable.id eq id }.singleOrNull()?.toNote()
    }

    suspend fun create(req: CreateNoteRequest): Note = newSuspendedTransaction(Dispatchers.IO, db) {
        val note = Note(
            id = UUID.randomUUID(),
            title = req.title,
            body = req.body,
            createdAt = Instant.now().truncatedTo(ChronoUnit.MILLIS),
        )
        NotesTable.insert {
            it[id] = note.id
            it[title] = note.title
            it[body] = note.body
            it[createdAt] = note.createdAt.toEpochMilli()
        }
        note
    }

    // update / delete follow the same shape
}
```

First, the constructor now takes a `Database`. Second — the only change that ripples outward at all — every method is now `suspend` and runs inside `newSuspendedTransaction(Dispatchers.IO, db)`. JDBC is blocking I/O, and Ktor handlers run on Netty's event-loop threads; blocking one of those threads on a disk read is how you stall the whole server. `Dispatchers.IO` moves the blocking call to a thread pool built for exactly that. And because Ktor's route handlers are *already* `suspend` lambdas, calling a `suspend` repository method from them needs **zero** edits to `NoteRoutes.kt`. The seam held: the file that teaches Ktor is bit-for-bit identical to before.

There's one small Exposed-version wrinkle worth flagging if you copy this: the `eq` inside `selectAll().where { ... }` resolves fine, but the `eq` inside `deleteWhere { ... }` did not — in recent Exposed the two lambdas have different receivers. The fix is a one-line import, `import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq`, and then both compile.

## Keeping the tests honest

Every test in the project spins up the whole app with `testApplication { application { module() } }`, and `module()` now opens a database. If they all shared one file they'd see each other's notes and the "list starts empty" assertion would flake. The path-resolution order from `NotesDatabase` earlier is what makes isolation a three-line fix — each test sets the system property to its own temp file before the app starts:

```kotlin
@TempDir lateinit var tmp: File

@BeforeTest fun isolateDb() {
    System.setProperty("notes.db.path", File(tmp, "notes-${UUID.randomUUID()}.db").absolutePath)
}

@AfterTest fun clearDb() = System.clearProperty("notes.db.path")
```

I used an on-disk temp file rather than `:memory:` on purpose: with `newSuspendedTransaction`, different transactions can land on different connections, and an in-memory SQLite database is scoped to a single connection — so an in-memory DB can appear to "lose" rows between calls. A real file under JUnit's `@TempDir` sidesteps that entirely and gets cleaned up for free.

## Making it actually survive on the cluster

A SQLite file is only as durable as the directory it lives in, and a container's filesystem is thrown away every time the container is recreated — which, on my setup, is *every deploy*. So persistence is really two changes: write the file somewhere, and make that somewhere outlive the container.

In the `Dockerfile`, a writable data directory owned by the non-root user the app runs as, plus the env var that points the path resolver at it:

```dockerfile
RUN mkdir -p /app/data && chown -R app:app /app/data
ENV NOTES_DB_PATH=/app/data/notes.db
```

And in my Ansible deploy config, a named Docker volume mounted at that path, matching the convention my other stateful services already use:

```yaml
-v kotlin-tutorial-data:/app/data
```

Named volumes live outside the container's lifecycle, so the stop-remove-recreate dance the deploy playbook does on `node5` leaves the data untouched. The deploy itself is unremarkable in the way I like: `node0` (my Mac mini control node) builds the arm64 image natively, pushes it to GHCR, and the Ansible playbook health-gates the swap on `node5`.

I verified the whole loop the only way that actually proves persistence — by killing the process. Locally: POST a note, stop the app, start it again pointing at the same file, GET the list, and watch the note still be there. Then in production after the deploy, `GET /notes` returns a clean `[ ]`, the schema having been created on first boot — and the note I added by hand a few minutes later is, satisfyingly, still there.

> **Try it.** The store on `node5` is live and waiting for company — [add your own note at `/notes`](https://kotlin-tutorial.michaellamb.dev/#notes). It'll outlive my next deploy right alongside mine.

## Two lessons in one sitting

This is just how a pedagogical codebase works. `kotlin-tutorial` is where I teach myself Kotlin by using it, and `/notes` is a clean example of doing that on two levels at once: the handlers teach me Ktor request/response idioms, and wiring a real backing store behind them teaches me a software-architecture pattern — how you persist what those handlers write down without disturbing the interface they're built on. Two lessons, learned together, kept in separate files (`NotesTable.kt`, `NotesDatabase.kt`, and the rewritten `NoteRepository.kt`) so each one stays legible on its own.

And the architecture half is worth taking with you on its own. In-memory storage behind a thin repository, backed by a few kilobytes of SQLite on disk, is enough to hold notes from every consumer of the API at once and trust them to still be there after the next deploy. That's not a toy — it's the honest minimum a great many small services actually need.

So take it further than I did. Pick the Kotlin feature you keep forgetting, decide what *your* service actually needs to remember — and what its real requirements are — then add the file, register it in `Routing.kt`, and let the deploy carry it to `node5` like the rest. The next post will tell you what it taught me.
