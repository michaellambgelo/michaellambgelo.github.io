---
layout: post
title: "Identifying unlabeled Pis with a systemd LED service"
date: 2026-05-06
category: infrastructure
image: "/seo/2026-05-06-cluster-led-id-systemd.png"
tags:
- homelab
- raspberry-pi
- cluster
- automation
- guide
published: true
---

The six-Pi cluster has been running since 2021, and the cases are clear acrylic with no stickers. Most days that doesn't matter — `node1` is just a hostname I `ssh` into. But last week two Pis stopped responding, and I had to walk over to the rack and figure out which two physical chassis to investigate.

I couldn't tell. There's no labeling.

Here's a small systemd service that fixes that for good: every Pi in the cluster perpetually blinks its green ACT LED N times — where N is the trailing digit of its hostname — pauses 3 seconds, and repeats. `node3` blinks three times. `node5` blinks five. Walk up to the rack, count the blinks per Pi, label the chassis, never forget again.

## How the LED works on Pi 4

`/sys/class/leds/ACT/` is the green activity LED's sysfs interface. By default it's wired to the `mmc0` trigger so it flickers on SD-card I/O. To take manual control:

```bash
echo none > /sys/class/leds/ACT/trigger      # disconnect from mmc0
echo 1    > /sys/class/leds/ACT/brightness   # on
echo 0    > /sys/class/leds/ACT/brightness   # off
echo mmc0 > /sys/class/leds/ACT/trigger      # restore default
```

Anything that wants to drive the LED needs root (sysfs writes are root-only) and needs to remember to put the `mmc0` trigger back on exit, or you've left users with a dead activity light.

## The script

`/usr/local/sbin/cluster-led-id.sh`:

```bash
#!/usr/bin/env bash
set -u

host=$(cat /etc/hostname 2>/dev/null || hostname)
count=$(echo "$host" | grep -oE '[0-9]+$' | head -1)
[ -z "$count" ] || [ "$count" -eq 0 ] 2>/dev/null && exit 0

LED=""
for cand in ACT led0 led1 PWR; do
  [ -d "/sys/class/leds/$cand" ] && LED=$cand && break
done
[ -z "$LED" ] && { echo "no controllable LED" >&2; exit 1; }

orig=$(grep -oP '\[\K[^]]+' "/sys/class/leds/$LED/trigger" 2>/dev/null || echo mmc0)

restore() {
  echo "$orig" > "/sys/class/leds/$LED/trigger" 2>/dev/null || true
}
trap restore TERM INT QUIT

echo none > "/sys/class/leds/$LED/trigger"
echo 0    > "/sys/class/leds/$LED/brightness"

while true; do
  for _ in $(seq 1 "$count"); do
    echo 1 > "/sys/class/leds/$LED/brightness"
    sleep 0.3
    echo 0 > "/sys/class/leds/$LED/brightness"
    sleep 0.25
  done
  sleep 3
done
```

Hostname-driven. Probes for `ACT` first, falls back to `led0`/`led1`/`PWR` so it survives kernel renames. Saves the original trigger and restores it on `SIGTERM` so `systemctl stop cluster-led-id` returns the LED cleanly to default.

## The systemd unit

`/etc/systemd/system/cluster-led-id.service`:

```ini
[Unit]
Description=Cluster node LED identification (blink count = hostname digit)
After=multi-user.target
DefaultDependencies=yes

[Service]
Type=simple
ExecStart=/usr/local/sbin/cluster-led-id.sh
Restart=always
RestartSec=2
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
```

`Restart=always` so a stuck pattern just relaunches. Logs go to the journal, including the "host=node3 LED=ACT count=3 orig_trigger=mmc0" line the script prints once at startup.

## Deploying to six nodes at once

Same install on every host:

```bash
for h in node1 node2 node3 node4 node5 node6; do
  scp -i ~/.ssh/cluster cluster-led-id.sh cluster-led-id.service "$h:/tmp/" &
done; wait

for h in node1 node2 node3 node4 node5 node6; do
  ssh -i ~/.ssh/cluster "$h" '
    sudo install -m 0755 /tmp/cluster-led-id.sh /usr/local/sbin/cluster-led-id.sh
    sudo install -m 0644 /tmp/cluster-led-id.service /etc/systemd/system/cluster-led-id.service
    sudo systemctl daemon-reload
    sudo systemctl enable --now cluster-led-id.service
  ' &
done; wait
```

Confirm:

```bash
for h in node1 node2 node3 node4 node5 node6; do
  printf "%s: %s\n" "$h" "$(ssh -i ~/.ssh/cluster "$h" 'systemctl is-active cluster-led-id.service')"
done
```

All six come back `active`. Walk to the rack, watch for one chassis blinking once, one twice, one three times, and so on. Slap a label on each.

## Why I like this

It's a tiny bit of code that solves a frustrating physical-world problem. There's no monitoring stack, no QR codes, no cloud anything. Each Pi knows which one it is, says so visibly, and stops talking when you ask it to.

The trick of *deriving* the blink count from the hostname digit means I never need a per-node configuration file. The same script and the same unit on every node, and the behavior diverges only because the hostnames diverge.

If I ever need a seventh Pi (`node7`), it'll blink seven times the moment systemd starts the service. No deploy step required.
