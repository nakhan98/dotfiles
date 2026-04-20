---
name: ddgs
description: Use when you need to search the web, find news, images, videos, or books, or extract content from a URL. Uses uv to run ddgs ephemerally with no persistent install.
disable-model-invocation: true
---

# ddgs — Web Search via uv

<!-- EXPERIMENTAL: Uses `uv tool run ddgs` to run searches ephemerally.
     uv downloads and caches ddgs on first run (~seconds). Subsequent runs are near-instant.
     Requires uv installed on the host or inside the dev container. -->

## Overview

Web search is provided by **ddgs** (Dux Distributed Global Search) — a metasearch library that
aggregates results from Bing, DuckDuckGo, Google, Brave, and others. `uv tool run` handles
the install and caching automatically — no pip install, no container management needed.

---

## Text Search

```bash
uv tool run ddgs text -q "YOUR QUERY" --max_results 5
```

## News Search

```bash
uv tool run ddgs news -q "YOUR QUERY" --max_results 5 --timelimit w
```

`--timelimit`: `d` (day), `w` (week), `m` (month), `y` (year)

## Images Search

```bash
uv tool run ddgs images -q "YOUR QUERY" --max_results 5
uv tool run ddgs images -q "YOUR QUERY" --color Blue --max_results 5
```

`--color`: `Red`, `Orange`, `Yellow`, `Green`, `Blue`, `Purple`, `Pink`, `Brown`, `Black`, `Gray`, `Teal`, `White`, `Monochrome`

## Videos Search

```bash
uv tool run ddgs videos -q "YOUR QUERY" --max_results 5
uv tool run ddgs videos -q "YOUR QUERY" --duration medium --max_results 5
```

`--duration`: `short`, `medium`, `long`

## Books Search

```bash
uv tool run ddgs books -q "YOUR QUERY" --max_results 5
```

## Extract Content from a URL

```bash
uv tool run ddgs extract -u "https://example.com"
uv tool run ddgs extract -u "https://example.com" -f text_plain
```

## Save Output

```bash
uv tool run ddgs text -q "YOUR QUERY" --max_results 5 -o /tmp/results.json
uv tool run ddgs text -q "YOUR QUERY" --max_results 5 -o /tmp/results.csv
```

---

## Proxy Support

Set the `DDGS_PROXY` environment variable to route through a proxy:

```bash
DDGS_PROXY="socks5h://127.0.0.1:9150" uv tool run ddgs text -q "YOUR QUERY"
```

## Quick Reference

| Parameter     | Values                                          | Default    |
|---------------|-------------------------------------------------|------------|
| `--max_results` | integer                                       | `10`       |
| `--page`      | integer (for paginating results)                | `1`        |
| `--region`    | `us-en`, `uk-en`, `de-de`, `ru-ru`, etc.       | `us-en`    |
| `--safesearch`| `on`, `moderate`, `off`                         | `moderate` |
| `--timelimit` | `d` (day), `w` (week), `m` (month), `y` (year) | none       |
| `--backend`   | `auto`, `all`, `bing`, `duckduckgo`, `google`, `brave`, `yandex`, `yahoo` | `auto` |

## Available Backends by Method

| Method   | Backends |
|----------|----------|
| `text`   | `bing`, `brave`, `duckduckgo`, `google`, `grokipedia`, `mojeek`, `yandex`, `yahoo`, `wikipedia` |
| `images` | `bing`, `duckduckgo` |
| `videos` | `duckduckgo` |
| `news`   | `bing`, `duckduckgo`, `yahoo` |
| `books`  | `annasarchive` |

## Troubleshooting

- **`uv: command not found`** — uv not installed; on host: `curl -LsSf https://astral.sh/uv/install.sh | sh`; in dev container: rebuild image
- **Slow first run** — uv is downloading and caching ddgs, subsequent runs will be fast
- **`RatelimitException`** — rate limited by search engine; try a different `--backend` or wait before retrying
- **`TimeoutException`** — increase timeout via `DDGS_TIMEOUT=10` env var or try a different backend
- **`DDGSException`** — general error; check query and backend availability
- **No results** — broaden the query or try `--backend all` to query all engines simultaneously
