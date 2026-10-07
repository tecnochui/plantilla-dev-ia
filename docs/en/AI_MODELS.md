# AI Models Guide

🌍 **Read this in:** [Español](../es/MODELOS_IA.md) | [English](AI_MODELS.md)

> Which model to use for each task, how much it costs, and how to keep the budget under control.

---

## Recommended budget

**$10-20 USD/month** with disciplined usage.

| Scenario | Monthly cost | Usage |
|----------|--------------|-------|
| **Minimum** | $5-10 | DeepSeek V4 Flash only via OpenRouter |
| **Recommended** | $10-15 | DeepSeek V4 Flash + occasional Qwen3 Coder Next |
| **Maximum** | $15-20 | The above + occasional Claude Sonnet via API |

---

## Models by task

### Initial documentation (free)

| Model | Where | For what |
|-------|-------|----------|
| **DeepSeek web** | chat.deepseek.com | PRD-SRD, SRS, Technical Proposal, SSD-TDD |
| **Gemini web** | gemini.google.com | Long documents (Proposal, SSD) |
| **Claude web** | claude.ai | Critical security decisions |

**Cost: $0.** These free versions do not connect to Zoo Code, but they work for copy/pasting documentation.

### Code and debugging (OpenRouter)

| Model | OpenRouter ID | Price (input/output) | When to use |
|-------|---------------|----------------------|-------------|
| **DeepSeek V4 Flash** | `deepseek/deepseek-v4-flash` | ~$0.04-0.14 / ~$0.08-0.28 | 80-90% of operations |
| **Qwen3 Coder Next** | `qwen/qwen3-coder-next` | ~$0.12 / ~$0.80 | Complex debugging, reasoning |
| **DeepSeek V4 Pro** | `deepseek/deepseek-v4-pro` | ~$0.87 / ~$0.87 | Only if Flash cannot solve it |
| **Claude Sonnet** | `anthropic/claude-sonnet-4.6` | ~$3 / ~$15 | Only extreme cases via API |

**Cost per typical session (100K input / 20K output):**

| Model | Cost per session |
|-------|------------------|
| DeepSeek V4 Flash | ~$0.008-0.020 |
| Qwen3 Coder Next | ~$0.026-0.028 |
| DeepSeek V4 Pro | ~$0.10-0.17 |
| Claude Sonnet | ~$0.60 |

**With $15/month and DeepSeek V4 Flash as the workhorse: hundreds of sessions per month.**

---

## Model strategy by phase

| Phase | Main model | Secondary model | Estimated cost |
|-------|-----------|-----------------|----------------|
| Documentation | DeepSeek web / Gemini web | Claude web | $0 |
| Planning (Architect) | DeepSeek V4 Flash | — | ~$0.01/session |
| Implementation (Code) | DeepSeek V4 Flash | — | ~$0.01/session |
| Debugging (Debug) | Qwen3 Coder Next | DeepSeek V4 Flash | ~$0.03/session |
| Security review | Claude web | DeepSeek web | $0 |
| Critical refactoring | Claude web | DeepSeek web | $0 |

---

## How to configure OpenRouter in Zoo Code

1. Get an API key at [openrouter.ai/keys](https://openrouter.ai/keys).
2. In Zoo Code, go to Settings → Providers → OpenRouter.
3. Paste the API key.
4. Select the models:
   - **Architect:** `deepseek/deepseek-v4-flash`
   - **Code:** `deepseek/deepseek-v4-flash`
   - **Debug:** `qwen/qwen3-coder-next`

---

## How to save

1. **Buy $10 in credits once** → unlocks 1,000 requests/day with free OpenRouter models.
2. **Use DeepSeek V4 Flash for everything** except complex debugging.
3. **Reserve Claude Sonnet via API** for cases that even the free web versions cannot solve.
4. **Do not leave Zoo Code running long tasks unsupervised** → it consumes tokens unnecessarily.
5. **Use Architect mode before Code** → prevents the AI from writing code without a plan.

---

## Limits of free web versions

| Model | Typical limit (2026) |
|-------|----------------------|
| DeepSeek web | No known daily limit |
| Gemini web | No known daily limit |
| Claude web | ~20-50 messages/day |
| ChatGPT web | ~20-50 messages/day |
| Qwen web | No known limit (verify) |

**Contingency:** If DeepSeek web limits to 20 messages/day, redistribute tasks to Gemini web and Qwen web.
