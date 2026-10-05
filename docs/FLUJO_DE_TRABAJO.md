# Flujo de Trabajo Completo

> Diagrama y explicación del proceso end-to-end, desde "quiero hacer un sistema" hasta "release en producción".

---

## Visión general

```
┌──────────────────────────────────────────────────────────────────────┐
│                        FASE 0: PREPARACIÓN                           │
│                                                                       │
│  ./setup.sh --install-tools                                          │
│  • Crea estructura de carpetas                                        │
│  • Copia archivos de configuración (AGENTS.md, workflows, etc.)      │
│  • Instala herramientas de seguridad (Semgrep, Trivy, Gitleaks)      │
│                                                                       │
│  Editar AGENTS.md → reemplazar [NOMBRE DEL PROYECTO]                 │
│  git add . && git commit -m "chore: initial setup"                   │
└──────────────────────────────────────────────────────────────────────┘
                                    ↓
┌──────────────────────────────────────────────────────────────────────┐
│                   FASE 1: DOCUMENTACIÓN FUNDACIONAL                   │
│                                                                       │
│  Paso 1: PRD-SRD        → ¿Qué construimos y para quién?             │
│          Modelo: DeepSeek web / Gemini web                            │
│          Validar → guardar en docs/PRD-SRD.md                        │
│                                                                       │
│  Paso 2: SRS            → Requisitos funcionales y no funcionales    │
│          Adjuntar: docs/PRD-SRD.md                                    │
│          Modelo: DeepSeek web                                         │
│          Validar → guardar en docs/SRS.md                             │
│                                                                       │
│  Paso 3: Propuesta Técnica → Stack, arquitectura, licencia           │
│          Adjuntar: docs/SRS.md                                        │
│          Modelo: DeepSeek web / Gemini web                            │
│          Validar → guardar en docs/Propuesta_Tecnica.md              │
│                                                                       │
│  Paso 4: SSD-TDD        → Diseño detallado (arquitectura, BD, API)   │
│          Adjuntar: docs/SRS.md + docs/Propuesta_Tecnica.md           │
│          Modelo: DeepSeek web                                         │
│          Validar → guardar en docs/SSD-TDD.md                        │
│                                                                       │
│  Paso 5: Mapeo NIST+OWASP → Cumplimiento de seguridad                │
│          Adjuntar: docs/SSD-TDD.md + docs/SRS.md                     │
│          Modelo: DeepSeek web / Claude web                            │
│          Validar → guardar en docs/Mapeo_NIST_OWASP.md               │
│                                                                       │
│  Paso 6: Estrategia Respaldos → Respaldos y retención de logs        │
│          Adjuntar: docs/SSD-TDD.md                                    │
│          Modelo: DeepSeek web                                         │
│          Validar → guardar en docs/Estrategia_Respaldos.md           │
│                                                                       │
│  Paso 7: Plan de Pruebas → Estrategia de testing completa            │
│          Adjuntar: docs/SRS.md + docs/SSD-TDD.md + Propuesta         │
│          Modelo: DeepSeek web / Gemini web                            │
│          Validar → guardar en docs/Plan_Pruebas.md                   │
│                                                                       │
│  ─────────────────────────────────────────────────────────────────   │
│  ✅ Los 7 documentos están aprobados. Ahora SÍ se puede codificar.   │
└──────────────────────────────────────────────────────────────────────┘
                                    ↓
┌──────────────────────────────────────────────────────────────────────┐
│                       FASE 2: DESARROLLO                             │
│                                                                       │
│  Para cada módulo del SSD-TDD:                                       │
│                                                                       │
│  Zoo Code (modo Architect) + DeepSeek V4 Flash                       │
│  → Prompt: "Lee AGENTS.md, docs/PRD-SRD.md, docs/SRS.md,             │
│     docs/SSD-TDD.md. Propón un plan para implementar [módulo]."      │
│                                                                       │
│  Zoo Code (modo Code) + DeepSeek V4 Flash                            │
│  → Prompt: "Implementa el módulo según el plan aprobado.             │
│     Sigue las convenciones del SSD."                                  │
│                                                                       │
│  Zoo Code (modo Debug) + Qwen3 Coder Next                            │
│  → Prompt: "Ejecuta tests, identifica el error, corrígelo,           │
│     re-ejecuta."                                                      │
│                                                                       │
│  Pre-commit hook valida en cada commit:                              │
│  • lint-staged (formato)                                              │
│  • Gitleaks (secretos)                                                │
│  • ESLint security / Bandit (SAST)                                    │
│  • commitlint (Conventional Commits)                                  │
└──────────────────────────────────────────────────────────────────────┘
                                    ↓
┌──────────────────────────────────────────────────────────────────────┐
│                    FASE 3: REVISIÓN DE SEGURIDAD                     │
│                                                                       │
│  git push → GitHub Actions ejecuta workflows en paralelo:            │
│                                                                       │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐                  │
│  │ tests.yml   │  │ sast.yml    │  │ sca.yml     │                  │
│  │ + Codecov   │  │ Semgrep     │  │ Trivy       │                  │
│  └─────────────┘  └─────────────┘  └─────────────┘                  │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐                  │
│  │ secrets.yml │  │ commitlint  │  │ dast.yml    │                  │
│  │ Gitleaks    │  │             │  │ OWASP ZAP   │                  │
│  └─────────────┘  └─────────────┘  └─────────────┘                  │
│                                                                       │
│  Si hay CRITICAL o HIGH → bloqueo de merge                           │
│  Si la cobertura baja o el patch no tiene 50% → bloqueo              │
└──────────────────────────────────────────────────────────────────────┘
                                    ↓
┌──────────────────────────────────────────────────────────────────────┐
│                          FASE 4: RELEASE                             │
│                                                                       │
│  git tag v1.0.0                                                      │
│  git push origin v1.0.0                                              │
│                                                                       │
│  → changelog.yml genera CHANGELOG.md automáticamente                 │
│  → Si deploy.yml está configurado, despliega a producción            │
└──────────────────────────────────────────────────────────────────────┘
```

---

## Flujo para proyecto existente sin documentación

Cuando te encuentras un sistema sin documentación (tuyo o de terceros):

```
1. ANÁLISIS FORENSE
   Zoo Code (modo Architect) + DeepSeek V4 Flash
   → Prompt: "Analiza este sistema. Genera docs/REGISTRO_FORENSE.md
      con inventario de módulos, flujo de datos, puntos de entrada,
      dependencias, zonas oscuras y hallazgos de seguridad."

2. GENERAR DOCUMENTACIÓN RETROSPECTIVA
   • README.md inverso (qué hace, cómo se usa)
   • CHANGELOG.md desde git log
   • PRD-SRD retrospectivo (lo que el código ya hace)
   • SRS retrospectivo
   • SSD-TDD retrospectivo

3. CONTINUAR DESARROLLO
   A partir de aquí, el flujo es el mismo que para un proyecto nuevo.
   AGENTS.md instruye a la IA a leer REGISTRO_FORENSE.md siempre.
```

---

## Tabla de decisiones rápidas

| Situación | Acción |
|-----------|--------|
| Proyecto nuevo | Fase 0 → 1 → 2 → 3 → 4 |
| Proyecto existente sin docs | Análisis forense → Documentación retrospectiva → Fase 2 |
| Proyecto existente con docs | Fase 2 (actualizar docs si es necesario) |
| Bug crítico en producción | Zoo Code Debug → fix → PR → merge |
| Nueva funcionalidad | Actualizar SRS → SSD-TDD → Fase 2 |
| Cambio de stack | Propuesta Técnica → SSD-TDD → Fase 2 |
