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

import type { ExtensionAPI, ExtensionContext } from "@mariozechner/pi-coding-agent";

const PLAN_TOOLS = ["read", "grep", "find", "ls"];
const BUILD_TOOLS = ["read", "grep", "find", "ls", "bash", "write", "edit"];

export default function (pi: ExtensionAPI) {
  let mode: "plan" | "build" = "plan";
  let returnToMode: "plan" | "build" | null = null;

  function applyMode(ctx: ExtensionContext) {
    if (mode === "plan") {
      pi.setActiveTools(PLAN_TOOLS);
      ctx.ui.setStatus("modes-ext", ctx.ui.theme.fg("muted", "mode: plan"));
    } else {
      pi.setActiveTools(BUILD_TOOLS);
      ctx.ui.setStatus("modes-ext", ctx.ui.theme.fg("success", "mode: build"));
    }
  }

  // Fix 1: reset on initial load
  pi.on("session_start", async (_event, ctx) => {
    mode = "plan";
    returnToMode = null;
    applyMode(ctx);
  });

  // Fix 2: reset on /new (session_start does not re-fire for new sessions)
  pi.on("session_switch", async (event, ctx) => {
    if (event.reason === "new") {
      mode = "plan";
      returnToMode = null;
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
