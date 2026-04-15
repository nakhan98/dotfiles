---
name: ddgs
description: Use when you need to search the web, find news, images, videos, or books, or extract content from a URL. Auto-detects whether running on the host or inside a dev container and uses the appropriate backend.
---

# ddgs — Web Search (Auto-detecting)

<!-- EXPERIMENTAL: This skill auto-detects the runtime environment and delegates
     to the appropriate backend:
       - HOST:          podman-compose lifecycle (~/dev/ddgs) → REST API at localhost:8000
       - DEV CONTAINER: uv tool run ddgs (ephemeral, no install required)
     See also: ddgs-podman and ddgs-uv skills for explicit invocation. -->

## Step 1 — Detect Runtime Environment

```bash
if [ -f /run/.containerenv ]; then
  echo "dev-container"
else
  echo "host"
fi
```

Then follow the section matching your environment below.

---

## If HOST: Podman Lifecycle

<!-- Uses the ddgs REST API container. Starts before query, stops after. -->

### 1a — Check for upstream updates

```bash
cd ~/dev/ddgs
git fetch
BEHIND=$(git rev-list HEAD..origin/main --count 2>/dev/null || echo 0)
echo "Commits behind upstream: $BEHIND"
```

- If `$BEHIND > 0` → pull and rebuild:
  ```bash
  git pull && podman-compose up -d --build
  ```
- If `$BEHIND == 0` → start existing image:
  ```bash
  podman-compose up -d
  ```

### 1b — Wait for healthy

```bash
for i in $(seq 1 15); do
  STATUS=$(curl -s http://localhost:8000/health | python3 -c "import sys,json; print(json.load(sys.stdin).get('status',''))" 2>/dev/null)
  [ "$STATUS" = "healthy" ] && echo "Ready" && break
  echo "Waiting... ($i)" && sleep 2
done
```

### 1c — Query (REST API)

**Text search:**
```bash
curl -s -X POST http://localhost:8000/search/text \
  -H "Content-Type: application/json" \
  -d '{"query": "YOUR QUERY", "max_results": 5}'
```

**News:** `POST /search/news` — extra param: `"timelimit": "d|w|m|y"`
**Images:** `POST /search/images`
**Videos:** `POST /search/videos`
**Books:** `POST /search/books`
**Extract URL:** `POST /extract` with `{"url": "https://..."}`

Response for text/news: `{"results": [{"title": "...", "href": "...", "body": "..."}]}`

### 1d — Stop the container

```bash
cd ~/dev/ddgs && podman-compose down
```

---

## If DEV CONTAINER: uv tool run

<!-- Uses uv to run ddgs ephemerally. No podman, no pip install required.
     First run downloads and caches ddgs (~seconds). Subsequent runs are near-instant. -->

**Text search:**
```bash
uv tool run ddgs text -q "YOUR QUERY" --max_results 5
```

**News:**
```bash
uv tool run ddgs news -q "YOUR QUERY" --max_results 5 --timelimit w
```

**Images:**
```bash
uv tool run ddgs images -q "YOUR QUERY" --max_results 5
```

**Videos:**
```bash
uv tool run ddgs videos -q "YOUR QUERY" --max_results 5
```

**Books:**
```bash
uv tool run ddgs books -q "YOUR QUERY" --max_results 5
```

**Extract URL:**
```bash
uv tool run ddgs extract -u "https://example.com"
uv tool run ddgs extract -u "https://example.com" -f text_plain
```

**Save output:**
```bash
uv tool run ddgs text -q "YOUR QUERY" --max_results 5 -o /tmp/results.json
```

---

## Quick Reference

| Parameter    | Values                                          | Default    |
|--------------|-------------------------------------------------|------------|
| `region`     | `us-en`, `uk-en`, `de-de`, `ru-ru`, etc.       | `us-en`    |
| `safesearch` | `on`, `moderate`, `off`                         | `moderate` |
| `timelimit`  | `d` (day), `w` (week), `m` (month), `y` (year) | none       |
| `max_results`| integer                                         | `10`       |
| `backend`    | `auto`, `bing`, `duckduckgo`, `google`, `brave`, `yandex`, `yahoo` | `auto` |

## Available Backends by Method

| Method   | Backends |
|----------|----------|
| `text`   | `bing`, `brave`, `duckduckgo`, `google`, `grokipedia`, `mojeek`, `yandex`, `yahoo`, `wikipedia` |
| `images` | `bing`, `duckduckgo` |
| `videos` | `duckduckgo` |
| `news`   | `bing`, `duckduckgo`, `yahoo` |
| `books`  | `annasarchive` |

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `podman-compose: command not found` | You're in the dev container — use `ddgs-uv` skill explicitly |
| `uv: command not found` | Try `~/.local/bin/uv`; rebuild dev container if missing |
| Container won't start | `podman logs ddgs_ddgs-api_1` |
| Health check times out | Container crashed — check logs above |
| No results | Try different `--backend` or broaden query |
| Port 8000 in use | `ss -tlnp \| grep 8000` |
