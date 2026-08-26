/**
 * Auto Session Name Extension
 *
 * Names pi sessions from recent conversation context. Uses the configured pi
 * model when possible, then falls back to a simple prompt-derived title.
 *
 * Usage:
 *   /auto-session-name              Regenerate from compacted and recent conversation context
 *
 * Environment:
 *   PI_AUTO_SESSION_NAME=0          Disable automatic naming
 *   PI_AUTO_SESSION_NAME_INTERVAL   User turns between renames (default: 20, 0 disables periodic renaming)
 *   PI_AUTO_SESSION_NAME_NOTIFY=0   Hide automatic naming notifications
 *   PI_AUTO_SESSION_NAME_PROVIDER   Override naming provider
 *   PI_AUTO_SESSION_NAME_MODEL      Override naming model
 */

import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { completeSimple, type AssistantMessage, type Model } from "@earendil-works/pi-ai/compat";

const MAX_PROMPT_CHARS = 2500;
const MAX_CONTEXT_SECTION_CHARS = 1200;
const MAX_TITLE_CHARS = 60;
const REQUEST_TIMEOUT_MS = 5000;
const RENAME_INTERVAL = Number(process.env.PI_AUTO_SESSION_NAME_INTERVAL || 20);

export default function (pi: ExtensionAPI) {
	let isNewSession = false;
	let lastRenameUserCount = 0;
	let warnedMissingProvider = false;

	const reconstructState = (ctx: ExtensionContext) => {
		lastRenameUserCount = countUserMessages(ctx);
		isNewSession = lastRenameUserCount === 0;
	};

	const renameSession = async (ctx: ExtensionContext, fallbackPrompt?: string, notify = true) => {
		const prompt = getConversationPrompt(ctx, fallbackPrompt);
		if (!prompt) {
			if (notify) ctx.ui.notify("Auto session naming: no user prompt found.", "warning");
			return;
		}

		if (notify) ctx.ui.notify("Generating session name…", "info");
		const title = await generateTitle(prompt, ctx);
		if (!title) {
			if (notify) ctx.ui.notify("Auto session naming: failed to generate title.", "warning");
			return;
		}

		pi.setSessionName(title);
		lastRenameUserCount = countUserMessages(ctx);
		if (notify) ctx.ui.notify(`Session named: ${title}`, "info");
	};

	pi.on("session_start", async (_event, ctx) => reconstructState(ctx));
	pi.on("session_tree", async (_event, ctx) => reconstructState(ctx));

	pi.registerCommand("auto-session-name", {
		description: "Regenerate the session name from compacted and recent conversation context",
		handler: async (_args, ctx) => renameSession(ctx),
	});

	pi.on("before_agent_start", (event, ctx) => {
		if (process.env.PI_AUTO_SESSION_NAME === "0" || !isNewSession) return;

		isNewSession = false;
		if (!pi.getSessionName()) {
			void renameSession(ctx, event.prompt, process.env.PI_AUTO_SESSION_NAME_NOTIFY !== "0");
		}
	});

	pi.on("agent_settled", async (_event, ctx) => {
		if (process.env.PI_AUTO_SESSION_NAME === "0" || RENAME_INTERVAL <= 0) return;

		const userCount = countUserMessages(ctx);
		if (userCount - lastRenameUserCount < RENAME_INTERVAL) return;

		lastRenameUserCount = userCount;
		await renameSession(ctx, undefined, process.env.PI_AUTO_SESSION_NAME_NOTIFY !== "0");
	});

	async function generateTitle(prompt: string, ctx: ExtensionContext): Promise<string | undefined> {
		const fromPiProvider = await generateTitleWithPiProvider(prompt, ctx);
		if (fromPiProvider) return fromPiProvider;

		return fallbackTitle(prompt);
	}

	async function generateTitleWithPiProvider(prompt: string, ctx: ExtensionContext): Promise<string | undefined> {
		const model = getNamingModel(ctx);
		if (!model) {
			if (!warnedMissingProvider && process.env.PI_AUTO_SESSION_NAME_NOTIFY === "1") {
				ctx.ui.notify("Auto session naming: no configured pi model found, using fallback title.", "warning");
				warnedMissingProvider = true;
			}
			return undefined;
		}

		const auth = await ctx.modelRegistry.getApiKeyAndHeaders(model);
		if (!auth.ok) return undefined;

		const controller = new AbortController();
		const timeout = setTimeout(() => controller.abort(), REQUEST_TIMEOUT_MS);

		try {
			const message = await completeSimple(
				model,
				{
					systemPrompt:
						"Create a short, descriptive coding-agent session title from the recent user/assistant conversation. Return only the title. No quotes. Max 6 words. Prefer imperative/noun phrase style.",
					messages: [
						{
							role: "user",
							content: prompt.slice(0, MAX_PROMPT_CHARS),
							timestamp: Date.now(),
						},
					],
				},
				{
					apiKey: auth.apiKey,
					headers: auth.headers,
					env: auth.env,
					maxTokens: 32,
					reasoning: "minimal",
					signal: controller.signal,
				},
			);

			return sanitizeTitle(extractAssistantText(message));
		} catch {
			return undefined;
		} finally {
			clearTimeout(timeout);
		}
	}
}

function getConversationPrompt(ctx: ExtensionContext, fallbackPrompt?: string): string | undefined {
	const entries = ctx.sessionManager.getBranch();
	const summary = entries.findLast((entry) => entry.type === "compaction")?.summary;
	const recentConversation = entries
		.filter((entry) => entry.type === "message" && ["user", "assistant"].includes(entry.message.role))
		.slice(-5)
		.map((entry) => {
			if (entry.type !== "message") return undefined;
			const text = getMessageText(entry.message.content);
			if (!text) return undefined;
			return `${entry.message.role === "user" ? "User" : "Assistant"}: ${text}`;
		})
		.filter((message): message is string => Boolean(message))
		.join("\n\n");

	const recent = recentConversation || (fallbackPrompt ? `User: ${fallbackPrompt}` : "");
	const sections = [
		summary ? `Compacted session:\n${summary.slice(0, MAX_CONTEXT_SECTION_CHARS)}` : "",
		recent ? `Recent conversation:\n${recent.slice(-MAX_CONTEXT_SECTION_CHARS)}` : "",
	].filter(Boolean);

	return sections.length ? sections.join("\n\n") : undefined;
}

function countUserMessages(ctx: ExtensionContext): number {
	return ctx.sessionManager
		.getBranch()
		.filter((entry) => entry.type === "message" && entry.message.role === "user").length;
}

function getMessageText(content: unknown): string | undefined {
	const text = typeof content === "string"
		? content
		: Array.isArray(content)
				? content
						.map((item) => {
							if (typeof item !== "object" || item === null) return undefined;
							const block = item as { type?: unknown; text?: unknown };
							return block.type === "text" && typeof block.text === "string" ? block.text : undefined;
						})
						.filter((item): item is string => Boolean(item))
						.join(" ")
				: undefined;

	return text?.replace(/\s+/g, " ").trim() || undefined;
}

function getNamingModel(ctx: ExtensionContext): Model<any> | undefined {
	const provider = process.env.PI_AUTO_SESSION_NAME_PROVIDER;
	const modelId = process.env.PI_AUTO_SESSION_NAME_MODEL;
	if (provider && modelId) return ctx.modelRegistry.find(provider, modelId);

	// Keep the naming call on the user's configured auth/provider, but prefer a
	// cheaper Codex model when available instead of spending the main model on it.
	if (ctx.model?.provider === "openai-codex") {
		return ctx.modelRegistry.find("openai-codex", modelId ?? "gpt-5.6-luna") ?? ctx.model;
	}

	return ctx.model;
}

function extractAssistantText(message: AssistantMessage): string | undefined {
	return message.content
		.filter((content) => content.type === "text")
		.map((content) => content.text)
		.join(" ");
}

function sanitizeTitle(value: string | undefined): string | undefined {
	const title = value
		?.replace(/[\r\n]+/g, " ")
		.replace(/^['"`“”‘’]+|['"`“”‘’]+$/g, "")
		.replace(/\s+/g, " ")
		.trim();

	if (!title) return undefined;

	return title.length <= MAX_TITLE_CHARS ? title : `${title.slice(0, MAX_TITLE_CHARS - 1).trim()}…`;
}

function fallbackTitle(prompt: string): string | undefined {
	const cleaned = prompt
		.replace(/^(?:Compacted session|Recent conversation|User|Assistant):/gim, " ")
		.replace(/```[\s\S]*?```/g, " ")
		.replace(/https?:\/\/\S+/g, " ")
		.replace(/[^\p{L}\p{N}\s_-]/gu, " ")
		.replace(/\s+/g, " ")
		.trim();

	if (!cleaned) return undefined;

	const words = cleaned.split(" ").slice(0, 6).join(" ");
	return sanitizeTitle(words);
}
