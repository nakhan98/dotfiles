// Extension: modes (lite)
//
// Provides a plan/build workflow for pi sessions.
//
// This is a stripped-down version that works alongside @gotgenes/pi-permission-system:
// - modes.ts handles plan/build mode switching (tool visibility, footer, context injection)
// - The permission system handles all allow/ask/deny gates (bash, write, edit, path, etc.)
//
// Spec:
// - On every session start (including /new), pi begins in "plan" mode (read-only for the LLM)
// - In plan mode, the LLM can only use: read, grep, find, ls, web_search
// - In plan mode, the LLM is informed of its restrictions via a hidden before_agent_start message
// - In plan mode, the user can still run !cmd (user bash) freely
// - /plan [msg]  — switches to plan mode, restricts LLM to read-only tools; if msg is provided,
//   prepends a mode-change note and sends it to the LLM immediately, then switches back to the
//   previous mode (only if mode actually changed)
// - /build [msg] — switches to build mode, gives LLM full tool access; if msg is provided,
//   prepends a mode-change note and sends it to the LLM immediately, then switches back to the
//   previous mode (only if mode actually changed)
// - /run — one-shot: switches to build mode, sends "Proceed" to trigger agent turn,
//   auto-returns to plan after agent finishes
// - If DEV_CONTAINER=1 is set, the footer is prefixed with "[DEV_CONTAINER]"
// - The current mode is shown in the footer as "mode: plan" (muted) or "mode: build" (green)
//   under the "modes-ext" status key
// - Mode resets to "plan" on each new session start
//
// Confirmation gates are handled by @gotgenes/pi-permission-system — this extension only
// controls tool visibility and provides the mode-switching UX.

import type { ExtensionAPI, ExtensionContext } from "@mariozechner/pi-coding-agent";

const PLAN_TOOLS = ["read", "grep", "find", "ls", "web_search"];
const BUILD_TOOLS = ["read", "grep", "find", "ls", "bash", "write", "edit", "web_search"];

export default function (pi: ExtensionAPI) {
  let mode: "plan" | "build" = "plan";
  let returnToMode: "plan" | "build" | null = null;

  const MODE_PREFIX = process.env.DEV_CONTAINER === "1" ? "[DEV_CONTAINER] " : "";

  function applyMode(ctx: ExtensionContext) {
    if (mode === "plan") {
      pi.setActiveTools(PLAN_TOOLS);
      ctx.ui.setStatus("modes-ext", ctx.ui.theme.fg("muted", `${MODE_PREFIX}mode: plan`));
    } else {
      pi.setActiveTools(BUILD_TOOLS);
      ctx.ui.setStatus("modes-ext", ctx.ui.theme.fg("success", `${MODE_PREFIX}mode: build`));
    }
  }

  // Reset to plan mode on session start
  pi.on("session_start", async (_event, ctx) => {
    mode = "plan";
    returnToMode = null;
    applyMode(ctx);
  });

  // Reset to plan mode on /new
  pi.on("session_switch", async (event, ctx) => {
    if (event.reason === "new") {
      mode = "plan";
      returnToMode = null;
      applyMode(ctx);
    }
  });

  // Auto-return to previous mode after one-shot /plan [msg], /build [msg], or /run
  pi.on("agent_end", async (_event, ctx) => {
    if (returnToMode !== null) {
      mode = returnToMode;
      returnToMode = null;
      applyMode(ctx);
      ctx.ui.notify(`Switched back to ${mode} mode`, "info");
    }
  });

  // Tell the LLM about its restrictions upfront in plan mode
  pi.on("before_agent_start", async () => {
    if (mode === "plan") {
      const prefix = process.env.DEV_CONTAINER === "1" ? "[DEV_CONTAINER] " : "";
      return {
        message: {
          customType: "modes-ext-context",
          content: `${prefix}[PLAN MODE] You are in read-only mode. Only read, grep, find, ls, and web_search are available. Do not attempt file modifications or bash commands.`,
          display: false,
        },
      };
    }
  });

  pi.registerCommand("plan", {
    description: "Switch to plan mode (LLM read-only: read, grep, find, ls, web_search)",
    handler: async (args, ctx) => {
      const previous = mode;
      mode = "plan";
      applyMode(ctx);
      ctx.ui.notify("Switched to plan mode", "info");
      if (args?.trim()) {
        returnToMode = previous !== mode ? previous : null;
        pi.sendUserMessage(`(Switched to plan mode — only read, grep, find, ls, and web_search available)\n\n${args.trim()}`);
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
        returnToMode = previous !== mode ? previous : null;
        pi.sendUserMessage(`(Switched to build mode — bash, write, and edit tools are now available)\n\n${args.trim()}`);
      }
    },
  });

  // One-shot: switch to build mode, send "Proceed" to trigger agent turn,
  // then auto-return to plan after agent finishes.
  // "Proceed" tells the LLM to continue with what it was previously suggesting.
  pi.registerCommand("run", {
    description: "One-shot: switch to build mode, send 'Proceed', auto-return to plan",
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
