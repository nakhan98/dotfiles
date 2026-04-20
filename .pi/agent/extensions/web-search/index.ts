// Extension: web-search
//
// Provides a first-class `web_search` tool for pi via ddgs.
//
// Spec:
// - Registers a custom tool named `web_search`
// - `web_search` supports two actions:
//   - `search`: search the web using ddgs
//   - `extract`: extract readable content from a URL using ddgs
//
// Search behavior:
// - Uses `uv tool run ddgs <searchType>` internally
// - Supported search types:
//   - `text`
//   - `news`
//   - `images`
//   - `videos`
//   - `books`
// - Requires `query` when `action === "search"`
// - Defaults:
//   - `searchType = "text"`
//   - `maxResults = 5`
//   - `region = "uk-en"`
// - Searches use ddgs backend auto-selection by default (no explicit backend is set)
// - Optional search parameters:
//   - `timelimit`: `d` | `w` | `m` | `y`
// - `timelimit` is only passed through for search types where ddgs supports it;
//   currently this implementation only forwards it for `news`
//
// Extract behavior:
// - Uses `uv tool run ddgs extract -u <url>` internally
// - Requires `url` when `action === "extract"`
// - Defaults:
//   - `extractFormat = "text_markdown"`
// - Supported extract formats:
//   - `text_markdown`
//   - `text_plain`
// - `text_markdown` maps to `-f text_markdown`
// - `text_plain` maps to `-f text_plain`
//
// Output behavior:
// - Returns a human-readable summary in `content` for the model
// - Returns structured machine-readable data in `details`
// - For `search`, `details` includes:
//   - `action`, `searchType`, `query`, `maxResults`, `timelimit`, `results`
// - For `extract`, `details` includes:
//   - `action`, `url`, `extractFormat`, `content`
// - If ddgs returns JSON, this tool attempts to parse it
// - If parsing fails, raw stdout is returned as text and in `details.rawOutput`
//
// Runtime behavior:
// - Uses `pi.exec()` to invoke `uv`
// - Streams a short progress update via `onUpdate()`
// - Respects cancellation via `signal`
// - Fails with a useful tool error message if:
//   - `uv` is not installed
//   - ddgs invocation fails
//   - required parameters are missing
//
// Notes:
// - This tool is designed to be added to the modes extension allowlist so it can
//   be used in plan mode without exposing general `bash`
// - This tool intentionally presents a stable model-facing API (`web_search`)
//   while allowing the backend implementation to change later if needed
//
// Suggested modes.ts integration:
// - Add `web_search` to PLAN_TOOLS
// - Add `web_search` to BUILD_TOOLS
//
// TODO (security / hardening):
// - Validate extract URLs and block localhost, private RFC1918 ranges, link-local addresses,
//   and metadata endpoints before invoking ddgs
// - Add explicit execution timeouts to `pi.exec()` calls
// - Consider truncating large extract payloads in `details.content`
// - Consider pinning the ddgs version used by `uv tool run` to reduce runtime drift
// - Tighten `maxResults` validation to integers only

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { StringEnum } from "@mariozechner/pi-ai";
import { Type, type Static } from "@sinclair/typebox";

const WebSearchParamsSchema = Type.Object({
  action: StringEnum(["search", "extract"] as const),

  query: Type.Optional(
    Type.String({
      description: "Search query. Required when action is 'search'.",
    }),
  ),

  url: Type.Optional(
    Type.String({
      description: "URL to extract content from. Required when action is 'extract'.",
    }),
  ),

  searchType: Type.Optional(
    StringEnum(["text", "news", "images", "videos", "books"] as const),
  ),

  maxResults: Type.Optional(
    Type.Number({
      description: "Maximum number of results to return for search.",
      minimum: 1,
      maximum: 20,
    }),
  ),

  timelimit: Type.Optional(StringEnum(["d", "w", "m", "y"] as const)),

  extractFormat: Type.Optional(
    StringEnum(["text_markdown", "text_plain"] as const),
  ),
});

type WebSearchParams = Static<typeof WebSearchParamsSchema>;

type SearchResult =
  | string
  | {
      title?: string;
      href?: string;
      url?: string;
      body?: string;
      snippet?: string;
      source?: string;
      date?: string;
      image?: string;
      thumbnail?: string;
      [key: string]: unknown;
    };

function normalizeQuery(query: string | undefined): string {
  return (query ?? "").trim();
}

function normalizeUrl(url: string | undefined): string {
  return (url ?? "").trim();
}

function isNonEmptyString(value: unknown): value is string {
  return typeof value === "string" && value.trim().length > 0;
}

function safeJsonParse(text: string): unknown | null {
  try {
    return JSON.parse(text);
  } catch {
    return null;
  }
}

function pickUrl(result: SearchResult): string | undefined {
  if (typeof result === "string") return undefined;
  if (isNonEmptyString(result.url)) return result.url;
  if (isNonEmptyString(result.href)) return result.href;
  return undefined;
}

function pickTitle(result: SearchResult): string | undefined {
  if (typeof result === "string") return result;
  if (isNonEmptyString(result.title)) return result.title;
  return undefined;
}

function pickSnippet(result: SearchResult): string | undefined {
  if (typeof result === "string") return undefined;
  if (isNonEmptyString(result.body)) return result.body;
  if (isNonEmptyString(result.snippet)) return result.snippet;
  return undefined;
}

function formatSearchResults(
  query: string,
  searchType: string,
  results: SearchResult[],
): string {
  if (results.length === 0) {
    return `No ${searchType} results found for: ${query}`;
  }

  const lines: string[] = [];
  lines.push(`Top ${results.length} ${searchType} results for: ${query}`);
  lines.push("");

  results.forEach((result, index) => {
    const title = pickTitle(result) ?? "(untitled)";
    const url = pickUrl(result);
    const snippet = pickSnippet(result);

    lines.push(`${index + 1}. ${title}`);
    if (url) lines.push(`   URL: ${url}`);
    if (snippet) lines.push(`   Summary: ${snippet}`);
    lines.push("");
  });

  return lines.join("\n").trim();
}

function formatExtractResult(url: string, content: string, format: string): string {
  const trimmed = content.trim();

  if (!trimmed) {
    return `No extractable content returned for URL: ${url}`;
  }

  const preview =
    trimmed.length > 4000 ? `${trimmed.slice(0, 4000)}\n\n[truncated]` : trimmed;

  return `Extracted content from ${url} (${format}):\n\n${preview}`;
}

function normalizeParsedSearchResults(parsed: unknown): SearchResult[] | null {
  if (Array.isArray(parsed)) {
    return parsed as SearchResult[];
  }

  if (parsed && typeof parsed === "object") {
    const record = parsed as Record<string, unknown>;

    if (Array.isArray(record.results)) {
      return record.results as SearchResult[];
    }

    if (Array.isArray(record.data)) {
      return record.data as SearchResult[];
    }
  }

  return null;
}

function buildSearchArgs(
  params: Required<Pick<WebSearchParams, "query" | "searchType" | "maxResults">> & {
    timelimit?: WebSearchParams["timelimit"];
  },
): string[] {
  const args = [
    "tool",
    "run",
    "ddgs",
    params.searchType,
    "-q",
    params.query,
    "--max_results",
    String(params.maxResults),
    "--region",
    "uk-en",
  ];

  if (params.timelimit && params.searchType === "news") {
    args.push("--timelimit", params.timelimit);
  }

  return args;
}

function buildExtractArgs(
  params: Required<Pick<WebSearchParams, "url">> & {
    extractFormat: "text_markdown" | "text_plain";
  },
): string[] {
  const args = ["tool", "run", "ddgs", "extract", "-u", params.url];

  args.push("-f", params.extractFormat);

  return args;
}

export default function (pi: ExtensionAPI) {
  pi.registerTool({
    name: "web_search",
    label: "Web Search",
    description: "Search the web for text, news, images, videos, or books, or extract content from a URL.",
    promptSnippet: "Search the web or extract page content from a URL",
    promptGuidelines: [
      "Use this tool when the user asks for current web information, recent news, or webpage content extraction.",
      "Use action='extract' when the user provides a URL and wants the page content inspected or summarized.",
    ],
    parameters: WebSearchParamsSchema,

    async execute(_toolCallId, params, signal, onUpdate, _ctx) {
      if (signal?.aborted) {
        return {
          content: [{ type: "text", text: "web_search cancelled before start." }],
          details: { cancelled: true },
        };
      }

      if (params.action === "search") {
        const query = normalizeQuery(params.query);
        const searchType = params.searchType ?? "text";
        const maxResults = params.maxResults ?? 5;
        const timelimit = params.timelimit;

        if (!query) {
          return {
            isError: true,
            content: [
              {
                type: "text",
                text: "web_search error: `query` is required when action is 'search'.",
              },
            ],
            details: { action: "search", error: "missing_query" },
          };
        }

        onUpdate?.({
          content: [{ type: "text", text: `Searching the web for: ${query}` }],
          details: { action: "search", query, searchType },
        });

        const args = buildSearchArgs({ query, searchType, maxResults, timelimit });
        const result = await pi.exec("uv", args, { signal });

        if (result.code !== 0) {
          const stderr = result.stderr?.trim() || "Unknown ddgs/uv error";
          const hint = stderr.includes("uv")
            ? "Ensure `uv` is installed and available in PATH."
            : "ddgs search failed.";

          return {
            isError: true,
            content: [
              {
                type: "text",
                text: `web_search error: ${hint}\n\n${stderr}`,
              },
            ],
            details: {
              action: "search",
              query,
              searchType,
              command: ["uv", ...args],
              exitCode: result.code,
              stderr: result.stderr,
              stdout: result.stdout,
            },
          };
        }

        const stdout = result.stdout?.trim() ?? "";
        const parsed = safeJsonParse(stdout);
        const normalizedResults = normalizeParsedSearchResults(parsed) ?? null;

        if (normalizedResults) {
          return {
            content: [
              {
                type: "text",
                text: formatSearchResults(query, searchType, normalizedResults),
              },
            ],
            details: {
              action: "search",
              query,
              searchType,
              maxResults,
              timelimit,
              results: normalizedResults,
            },
          };
        }

        const fallbackText = stdout || `Search completed for: ${query}`;

        return {
          content: [{ type: "text", text: fallbackText }],
          details: {
            action: "search",
            query,
            searchType,
            maxResults,
            timelimit,
            rawOutput: stdout,
            parsed: parsed ?? null,
          },
        };
      }

      const url = normalizeUrl(params.url);
      const extractFormat = params.extractFormat ?? "text_markdown";

      if (!url) {
        return {
          isError: true,
          content: [
            {
              type: "text",
              text: "web_search error: `url` is required when action is 'extract'.",
            },
          ],
          details: { action: "extract", error: "missing_url" },
        };
      }

      onUpdate?.({
        content: [{ type: "text", text: `Extracting content from: ${url}` }],
        details: { action: "extract", url, extractFormat },
      });

      const args = buildExtractArgs({ url, extractFormat });
      const result = await pi.exec("uv", args, { signal });

      if (result.code !== 0) {
        const stderr = result.stderr?.trim() || "Unknown ddgs/uv error";
        const hint = stderr.includes("uv")
          ? "Ensure `uv` is installed and available in PATH."
          : "ddgs extract failed.";

        return {
          isError: true,
          content: [
            {
              type: "text",
              text: `web_search error: ${hint}\n\n${stderr}`,
            },
          ],
          details: {
            action: "extract",
            url,
            extractFormat,
            command: ["uv", ...args],
            exitCode: result.code,
            stderr: result.stderr,
            stdout: result.stdout,
          },
        };
      }

      const stdout = result.stdout?.trim() ?? "";

      return {
        content: [
          {
            type: "text",
            text: formatExtractResult(url, stdout, extractFormat),
          },
        ],
        details: {
          action: "extract",
          url,
          extractFormat,
          content: stdout,
        },
      };
    },
  });
}
