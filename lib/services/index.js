const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");
const admin = require("firebase-admin");
const fetch = require("node-fetch");

admin.initializeApp();

const CLAUDE_API_KEY = defineSecret("CLAUDE_API_KEY");

/**
 * Callable Cloud Function — the Flutter app calls this instead of
 * hitting api.anthropic.com directly. The API key lives only here,
 * as a Firebase Secret, never inside the app bundle.
 *
 * Deploy with:
 *   firebase functions:secrets:set CLAUDE_API_KEY
 *   firebase deploy --only functions
 *
 * Call from Flutter with the `cloud_functions` package:
 *   final callable = FirebaseFunctions.instance.httpsCallable('askClaude');
 *   final result = await callable.call({'prompt': prompt, 'maxTokens': 600});
 *   final text = result.data['text'];
 */
exports.askClaude = onCall(
  { secrets: [CLAUDE_API_KEY], cors: true },
  async (request) => {
    // Only signed-in users of the app may call this.
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "Sign in karke dobara koshish karein."
      );
    }

    const prompt = request.data?.prompt;
    const maxTokens = request.data?.maxTokens || 600;

    if (!prompt || typeof prompt !== "string") {
      throw new HttpsError("invalid-argument", "'prompt' zaroori hai.");
    }

    try {
      const response = await fetch("https://api.anthropic.com/v1/messages", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "x-api-key": CLAUDE_API_KEY.value(),
          "anthropic-version": "2023-06-01",
        },
        body: JSON.stringify({
          model: "claude-sonnet-4-6",
          max_tokens: maxTokens,
          messages: [{ role: "user", content: prompt }],
        }),
      });

      if (!response.ok) {
        const errText = await response.text();
        console.error("Anthropic API error:", response.status, errText);
        throw new HttpsError("internal", "AI se jawab nahi mila.");
      }

      const data = await response.json();
      const text = (data.content || [])
        .filter((c) => c.type === "text")
        .map((c) => c.text)
        .join("\n");

      return { text };
    } catch (err) {
      console.error("askClaude failed:", err);
      throw new HttpsError("internal", "AI Mediator se connection nahi ho saka.");
    }
  }
);