# Post Template

This is a template for creating new blog posts. 

## Create a new post

1. Copy this file to the `_posts` directory and rename it following the format: `YYYY-MM-DD-title.md`.
2. **Alternatively**, the `jekyll-admin` gem provides a user-friendly admin panel can be used to create a new post. Start the jekyll server locally with `bundle exec jekyll serve` and use `http://localhost:4000/admin`

> **Note:** Please refer to `_templates/taxonomy.md` for the complete list of standardized categories and tags.

- A post should have one category
- Include 2-5 relevant tags
- Update the taxonomy document to add new categories or tags

# Frontmatter template
```
---

layout: post
title: "Your Post Title Here"
date: YYYY-MM-DD
category: category-name
image: "/seo/YYYY-MM-DD.png"
tags:

- tag1
- tag2
- tag3

published: true

---
```

Your post content here. Some guidelines:

1. Use proper markdown formatting
2. Include code blocks with language specification:

   ```python
   def example():
       return "Hello, World!"
   ```

1. Use proper heading hierarchy (H2 -> H3 -> H4, as H1 is reserved for the post title)
2. Include alt text for images:

   ![Alt text for image](image-url)

## SEO Guidelines

1. Always include a relevant image in the front matter
2. Keep titles under 60 characters
3. Use descriptive categories and tags from the taxonomy document
4. Ensure the post has a clear description

## Formatting Tips

1. Break up long paragraphs
2. Use lists and headings for better readability
3. Include code examples where relevant
4. Link to related posts when possible
