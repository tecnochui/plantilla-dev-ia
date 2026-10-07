# Guía de Modelos de IA

🌍 **Lee esto en:** [Español](MODELOS_IA.md) | [English](../en/AI_MODELS.md)

> Qué modelo usar para cada tarea, cuánto cuesta, y cómo mantener el presupuesto bajo control.

---

## Presupuesto recomendado

**$10-20 USD/mes** con uso disciplinado.

| Escenario | Costo mensual | Uso |
|-----------|---------------|-----|
| **Mínimo** | $5-10 | Solo DeepSeek V4 Flash vía OpenRouter |
| **Recomendado** | $10-15 | DeepSeek V4 Flash + Qwen3 Coder Next ocasional |
| **Máximo** | $15-20 | Los anteriores + Claude Sonnet puntual vía API |

---

## Modelos por tarea

### Documentación inicial (gratis)

| Modelo | Dónde | Para qué |
|--------|-------|----------|
| **DeepSeek web** | chat.deepseek.com | PRD-SRD, SRS, Propuesta Técnica, SSD-TDD |
| **Gemini web** | gemini.google.com | Documentos largos (Propuesta, SSD) |
| **Claude web** | claude.ai | Decisiones críticas de seguridad |

**Costo: $0.** Estas versiones gratuitas no se conectan a Zoo Code, pero sirven para copiar/pegar la documentación.

### Código y depuración (OpenRouter)

| Modelo | OpenRouter ID | Precio (input/output) | Cuándo usar |
|--------|---------------|----------------------|-------------|
| **DeepSeek V4 Flash** | `deepseek/deepseek-v4-flash` | ~$0.04-0.14 / ~$0.08-0.28 | 80-90% de las operaciones |
| **Qwen3 Coder Next** | `qwen/qwen3-coder-next` | ~$0.12 / ~$0.80 | Depuración compleja, razonamiento |
| **DeepSeek V4 Pro** | `deepseek/deepseek-v4-pro` | ~$0.87 / ~$0.87 | Solo si Flash no resuelve |
| **Claude Sonnet** | `anthropic/claude-sonnet-4.6` | ~$3 / ~$15 | Solo casos extremos vía API |

**Costo por sesión típica (100K input / 20K output):**

| Modelo | Costo por sesión |
|--------|------------------|
| DeepSeek V4 Flash | ~$0.008-0.020 |
| Qwen3 Coder Next | ~$0.026-0.028 |
| DeepSeek V4 Pro | ~$0.10-0.17 |
| Claude Sonnet | ~$0.60 |

**Con $15/mes y DeepSeek V4 Flash como caballo de batalla: cientos de sesiones al mes.**

---

## Estrategia de modelos por fase

| Fase | Modelo principal | Modelo secundario | Costo estimado |
|------|------------------|-------------------|----------------|
| Documentación | DeepSeek web / Gemini web | Claude web | $0 |
| Planificación (Architect) | DeepSeek V4 Flash | — | ~$0.01/sesión |
| Implementación (Code) | DeepSeek V4 Flash | — | ~$0.01/sesión |
| Depuración (Debug) | Qwen3 Coder Next | DeepSeek V4 Flash | ~$0.03/sesión |
| Revisión de seguridad | Claude web | DeepSeek web | $0 |
| Refactorización crítica | Claude web | DeepSeek web | $0 |

---

## Cómo configurar OpenRouter en Zoo Code

1. Obtener API key en [openrouter.ai/keys](https://openrouter.ai/keys).
2. En Zoo Code, ir a Settings → Providers → OpenRouter.
3. Pegar la API key.
4. Seleccionar los modelos:
   - **Architect:** `deepseek/deepseek-v4-flash`
   - **Code:** `deepseek/deepseek-v4-flash`
   - **Debug:** `qwen/qwen3-coder-next`

---

## Cómo ahorrar

1. **Comprar $10 en créditos una vez** → desbloquea 1,000 requests/día con modelos gratuitos de OpenRouter.
2. **Usar DeepSeek V4 Flash para todo** excepto depuración compleja.
3. **Reservar Claude Sonnet vía API** para casos que ni la web gratuita resuelve.
4. **No dejar Zoo Code ejecutando tareas largas sin supervisión** → consume tokens innecesariamente.
5. **Usar modo Architect antes de Code** → evita que la IA escriba código sin plan.

---

## Límites de las versiones gratuitas web

| Modelo | Límite típico (2026) |
|--------|----------------------|
| DeepSeek web | Sin límite diario conocido |
| Gemini web | Sin límite diario conocido |
| Claude web | ~20-50 mensajes/día |
| ChatGPT web | ~20-50 mensajes/día |
| Qwen web | Sin límite conocido (verificar) |

**Contingencia:** Si DeepSeek web limita a 20 mensajes/día, redistribuir tareas a Gemini web y Qwen web.
