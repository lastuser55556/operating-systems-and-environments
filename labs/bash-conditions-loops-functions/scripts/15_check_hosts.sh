#!/usr/bin/env bash
check_host() { ping -c 1 -W 2 "$1" >/dev/null 2>&1 && echo "$1 — доступен" || echo "$1 — недоступен"; }
hosts=(127.0.0.1 8.8.8.8 example.com)
for host in "${hosts[@]}"; do check_host "$host"; done
