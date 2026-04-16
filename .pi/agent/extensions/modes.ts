// Extension: modes
//
// Provides a plan/build workflow for pi sessions.
//
// Spec:
// - On every session start (including /new), pi begins in "plan" mode (read-only for the LLM)
// - In plan mode, the LLM can only use: read, grep, find, ls
// - In plan mode, the LLM is informed of its restrictions via a hidden before_agent_start message
// - In plan mode, the user can still run !cmd (user bash) freely
// - /plan [msg]  — switches to plan mode, restricts LLM to read-only tools; if msg is provided, prepends a mode-change note and sends it to the LLM immediately, then switches back to the previous mode (only if mode actually changed)
// - /build [msg] — switches to build mode, gives LLM full tool access; if msg is provided, prepends a mode-change note and sends it to the LLM immediately, then switches back to the previous mode (only if mode actually changed)
// - The current mode is shown in the footer as "mode: plan" (muted) or "mode: build" (green) under the "modes-ext" status key
// - Mode resets to "plan" on each new session start
//
// Write confirmation gate:
// - Gate is always active in build mode (no toggle command)
// - The LLM is prompted before each bash/write/edit call: Proceed / Accept all / Block
// - "Accept all" silences that specific tool for the remainder of the session
// - Gate resets on new session only (accepted tools persist across /plan <-> /build switches)
// - Footer always shows per-tool status: "mode: build [bash:ask, write:ask, edit:ask]"
//
// TODO: env var PI_CONFIRM_WRITES=0 to disable gate entirely at startup (for CI/power users)
// TODO: "Accept all tools" option in dialog to silence all tools mid-session in one go

import type { ExtensionAPI, ExtensionContext } from "@mariozechner/pi-coding-agent";

const PLAN_TOOLS = ["read", "grep", "find", "ls"];
const BUILD_TOOLS = ["read", "grep", "find", "ls", "bash", "write", "edit"];
const WRITE_TOOLS = ["bash", "write", "edit"];

export default function (pi: ExtensionAPI) {
  let mode: "plan" | "build" = "plan";
  let returnToMode: "plan" | "build" | null = null;
  let acceptedTools = new Set<string>();

  function toolStatus(tool: string): string {
    return acceptedTools.has(tool) ? "ok" : "ask";
  }

  function applyMode(ctx: ExtensionContext) {
    if (mode === "plan") {
      pi.setActiveTools(PLAN_TOOLS);
      ctx.ui.setStatus("modes-ext", ctx.ui.theme.fg("muted", "mode: plan"));
    } else {
      pi.setActiveTools(BUILD_TOOLS);
      const parts = WRITE_TOOLS.map(t => `${t}:${toolStatus(t)}`).join(", ");
      ctx.ui.setStatus("modes-ext", ctx.ui.theme.fg("success", `mode: build [${parts}]`));
    }
  }

  // Fix 1: reset on initial load
  pi.on("session_start", async (_event, ctx) => {
    mode = "plan";
    returnToMode = null;
    acceptedTools = new Set();
    applyMode(ctx);
  });

  // Fix 2: reset on /new (session_start does not re-fire for new sessions)
  pi.on("session_switch", async (event, ctx) => {
    if (event.reason === "new") {
      mode = "plan";
      returnToMode = null;
      acceptedTools = new Set();
      applyMode(ctx);
    }
  });

  pi.on("agent_end", async (_event, ctx) => {
    if (returnToMode !== null) {
      mode = returnToMode;
      returnToMode = null;
      applyMode(ctx);
      ctx.ui.notify(`Switched back to ${mode} mode`, "info");
    }
  });

  // Fix 3: tell the LLM about its restrictions upfront
  pi.on("before_agent_start", async () => {
    if (mode === "plan") {
      return {
        message: {
          customType: "modes-ext-context",
          content: "[PLAN MODE] You are in read-only mode. Only read, grep, find, and ls are available. Do not attempt file modifications or bash commands.",
          display: false,
        },
      };
    }
  });

  pi.registerCommand("plan", {
    description: "Switch to plan mode (LLM read-only: read, grep, find, ls)",
    handler: async (args, ctx) => {
      const previous = mode;
      mode = "plan";
      applyMode(ctx);
      ctx.ui.notify("Switched to plan mode", "info");
      if (args?.trim()) {
        // Fix 4: only return to previous mode if it was actually different
        returnToMode = previous !== mode ? previous : null;
        pi.sendUserMessage(`(Switched to plan mode — only read, grep, find, ls available)\n\n${args.trim()}`);
      }
    },
  });

  pi.registerCommand("build", {
    description: "Switch to build mode (LLM has full tool access)",
    handler: async (args, ctx) => {
      const previous = mode;
      mode = "build";
      applyMode(ctx);
      ctx.ui.notify("Switched to build mode", "success");
      if (args?.trim()) {
        // Fix 4: only return to previous mode if it was actually different
        returnToMode = previous !== mode ? previous : null;
        pi.sendUserMessage(`(Switched to build mode — bash, write, and edit tools are now available)\n\n${args.trim()}`);
      }
    },
  });

  // Write confirmation gate
  pi.on("tool_call", async (event, ctx) => {
    if (mode !== "build") return;
    if (!WRITE_TOOLS.includes(event.toolName)) return;
    if (acceptedTools.has(event.toolName)) return;

    if (!ctx.hasUI) {
      return { block: true, reason: "Write confirmation gate is active but no UI is available" };
    }

    const choice = await ctx.ui.select(
      `Allow ${event.toolName}? ("Accept all" = skip future ${event.toolName} confirmations)`,
      ["Proceed", "Accept all", "Block"]
    );

    if (choice === "Accept all") {
      acceptedTools.add(event.toolName);
      applyMode(ctx); // update footer to reflect new accepted state
      ctx.ui.notify(`Won't ask again for ${event.toolName} this session`, "info");
      return;
    }

    if (choice === "Block" || choice === null) {
      return { block: true, reason: "Blocked by user" };
    }

    // "Proceed" — allow through
  });

  // TESTING: /run shortcut command
  pi.registerCommand("run", {
    description: "Shortcut: switch to build mode, send 'Proceed', then return to previous mode",
    handler: async (_args, ctx) => {
      const previous = mode;
      mode = "build";
      applyMode(ctx);
      ctx.ui.notify("Switched to build mode", "success");
      returnToMode = previous !== mode ? previous : null;
      pi.sendUserMessage("(Switched to build mode — bash, write, and edit tools are now available)\n\nProceed");
    },
  });
}
