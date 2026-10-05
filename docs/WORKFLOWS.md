# Workflows de GitHub Actions

> Documentación de los 7 workflows que se ejecutan automáticamente en cada proyecto creado desde `plantilla-dev-ia`.

---

## Índice

| Workflow | Se ejecuta en | Bloquea merge |
|----------|---------------|---------------|
| [`tests.yml`](#testsyml) | PR + push a main | Sí |
| [`commitlint.yml`](#commitlintyml) | PR | Sí |
| [`sast.yml`](#sastyml) | PR + push a main | Sí (CRITICAL, HIGH) |
| [`sca.yml`](#scayml) | PR + push a main | Sí (CRITICAL, HIGH) |
| [`secrets.yml`](#secretsyml) | PR + push a main | Sí |
| [`dast.yml`](#dastyml) | Post-deploy a staging | No (informativo) |
| [`changelog.yml`](#changelogyml) | Creación de tag `v*` | No |

---

## `tests.yml`

**Propósito:** Ejecutar tests unitarios, generar cobertura y subirla a Codecov.

**Se dispara en:**
- Pull requests a `main`, `master`, `develop`
- Push a `main`, `master`

**Qué hace:**

```
1. Detecta los stacks presentes (Node.js, Python)
2. Para Node.js:
   - Matriz: [20.x, 22.x]
   - npm ci
   - npm run lint
   - npm test con cobertura
   - Sube artefacto de cobertura
3. Para Python:
   - Matriz: [3.11, 3.12, 3.13]
   - pip install -r requirements.txt
   - ruff check
   - pytest con cobertura
   - Sube artefacto de cobertura
4. Job separado: descarga todos los artefactos y sube a Codecov
```

**Secretos requeridos:**
- `CODECOV_TOKEN` (obligatorio para subir cobertura)

**Umbral de bloqueo:**
- Fallo de tests unitarios
- Cobertura por debajo del 80% global
- Cobertura del patch (código nuevo) por debajo del 50%

**Configuración:**
- `codecov.yml` en la raíz define los umbrales
- Cobertura del patch y del proyecto configuradas como `informational: false` (bloquean)

**Cómo saltarlo temporalmente:**
- Añadir `[skip ci]` al mensaje del commit (evita toda la CI)
- Añadir `[skip codecov]` al título del PR (solo omite el check de Codecov)

**Troubleshooting:**

| Problema | Causa | Solución |
|----------|-------|----------|
| `npm ci` falla | `package-lock.json` desactualizado | `npm install` local y commit del lock |
| `pytest` no encuentra tests | Configuración de pytest ausente | Crear `pytest.ini` o `pyproject.toml` |
| Codecov no aparece | Token no configurado | Añadir `CODECOV_TOKEN` en GitHub Secrets |
| Cobertura baja | Falta cobertura en archivos nuevos | Añadir tests o excluir archivos en `codecov.yml` |

---

## `commitlint.yml`

**Propósito:** Validar que los mensajes de commit sigan **Conventional Commits**.

**Se dispara en:**
- Pull requests a `main`, `master`

**Qué hace:**
1. Checkout con `fetch-depth: 0` (necesario para ver todos los commits del PR)
2. Instala `@commitlint/cli` y `@commitlint/config-conventional`
3. Ejecuta `commitlint` sobre todos los commits del PR

**Secretos requeridos:** Ninguno.

**Umbral de bloqueo:**
- Cualquier commit que no siga Conventional Commits

**Formatos válidos:**
```
feat(scope): descripción
fix(scope): descripción
security(scope): descripción
docs(scope): descripción
chore(scope): descripción
refactor(scope): descripción
test(scope): descripción
perf(scope): descripción
ci(scope): descripción
build(scope): descripción
revert(scope): descripción
```

**Configuración:**
- `commitlint.config.js` en la raíz define las reglas

**Cómo saltarlo:**
- Corregir el mensaje con `git commit --amend`
- Si ya está pusheado: `git rebase -i` y `git push --force-with-lease`

---

## `sast.yml`

**Propósito:** Análisis estático de seguridad (SAST) con Semgrep.

**Se dispara en:**
- Pull requests (cualquier rama)
- Push a `main`

**Qué hace:**
1. Ejecuta Semgrep en un contenedor oficial
2. Aplica los rulesets: `p/owasp-top-ten`, `p/security-audit`, `p/secrets`
3. Genera output en formato SARIF
4. Sube el SARIF a GitHub Security (pestaña "Security" → "Code scanning")

**Secretos requeridos:** Ninguno.

**Umbral de bloqueo:**
- Hallazgos CRITICAL
- Hallazgos HIGH

**Cómo ver los resultados:**
- Pestaña "Security" del repo → "Code scanning alerts"
- O en la sección "Checks" del PR

**Cómo saltarlo:**
- No se puede saltar directamente. Si un hallazgo es falso positivo:
  1. Añadir un comentario en el código: `# nosemgrep: rule-id`
  2. Documentar la excepción en `docs/Plan_Pruebas.md` → sección 9

**Troubleshooting:**

| Problema | Causa | Solución |
|----------|-------|----------|
| Semgrep tarda mucho | Ruleset muy amplio | Reducir a `p/owasp-top-ten` |
| Falsos positivos | Reglas muy genéricas | Añadir `# nosemgrep` con justificación |
| No sube SARIF | Falta permiso `security-events: write` | Verificar `permissions` en el workflow |

---

## `sca.yml`

**Propósito:** Análisis de composición de software (SCA) con Trivy.

**Se dispara en:**
- Pull requests (cualquier rama)
- Push a `main`

**Qué hace:**
1. Ejecuta Trivy en modo filesystem (`scan-type: fs`)
2. Escanea dependencias del proyecto
3. Filtra por severidad `CRITICAL,HIGH`
4. Genera SARIF y lo sube a GitHub Security
5. Falla si encuentra hallazgos (`exit-code: 1`)

**Secretos requeridos:** Ninguno.

**Umbral de bloqueo:**
- Vulnerabilidades CRITICAL en dependencias
- Vulnerabilidades HIGH en dependencias

**Acción crítica:**
- La acción `aquasecurity/trivy-action@0.35.0` sufrió un compromiso de cadena de suministro en marzo de 2026. **Verifica el SHA del commit** antes de usar.

**Cómo saltarlo:**
- Actualizar la dependencia vulnerable
- Si no hay actualización disponible: documentar excepción en `docs/Plan_Pruebas.md` y añadir un comentario en `.trivyignore`

---

## `secrets.yml`

**Propósito:** Detección de secretos hardcodeados con Gitleaks + detect-secrets.

**Se dispara en:**
- Pull requests (cualquier rama)
- Push a `main`

**Qué hace:**
- **Job 1 (Gitleaks):** escanea todo el historial de Git
- **Job 2 (detect-secrets):** escanea contra `.secrets.baseline`

**Secretos requeridos:**
- `GITHUB_TOKEN` (automático, provisto por GitHub Actions)

**Umbral de bloqueo:**
- Cualquier secreto nuevo detectado (no registrado en baseline)

**Configuración:**
- `.gitleaks.toml` define reglas personalizadas (API keys de IA, etc.)
- `.secrets.baseline` registra falsos positivos conocidos

**Cómo saltarlo:**
- Si es falso positivo: añadirlo a `[allowlist]` en `.gitleaks.toml` o al `.secrets.baseline`
- Si es real: eliminar el secreto, rotarlo, y usar `.env` en su lugar

**Troubleshooting:**

| Problema | Causa | Solución |
|----------|-------|----------|
| Gitleaks reporta API key de IA | Es una clave real o placeholder | Verificar si es real → rotar. Si es placeholder → añadir a allowlist |
| detect-secrets reporta muchos falsos positivos | Strings largos no secretos | Añadir al `.secrets.baseline` |
| Gitleaks escanea commits antiguos | Escanea todo el historial | Es el comportamiento correcto. Corregir en el código actual |

---

## `dast.yml`

**Propósito:** Análisis dinámico de seguridad (DAST) con OWASP ZAP.

**Se dispara en:**
- Después de que `Deploy to Staging` se complete (`workflow_run`)
- Manualmente (`workflow_dispatch`)

**Qué hace:**
1. Ejecuta ZAP Baseline Scan contra `https://staging.tu-dominio.com`
2. Genera reporte HTML
3. Sube el reporte como artefacto

**Secretos requeridos:** Ninguno (usa el target configurado en el YAML).

**Umbral de bloqueo:**
- **No bloquea** merge. Es informativo.

**Configuración requerida:**
- Cambiar `target: 'https://staging.tu-dominio.com'` por tu URL real de staging
- Este workflow **no se ejecuta** hasta que configures un destino de staging

**Cómo ver los resultados:**
- Descargar el artefacto `zap-report` desde la pestaña "Actions"

**Troubleshooting:**

| Problema | Causa | Solución |
|----------|-------|----------|
| `workflow_run` no se dispara | El workflow `Deploy to Staging` no existe | Renombrar el workflow de deploy a `Deploy to Staging` |
| ZAP falla al conectar | Target no responde o no existe | Verificar que staging esté accesible |
| Muchos falsos positivos | Baseline scan detecta todo | Revisar manualmente. ZAP Baseline es conservador |

---

## `changelog.yml`

**Propósito:** Generar `CHANGELOG.md` automáticamente desde los commits.

**Se dispara en:**
- Push de un tag `v*` (ej. `v1.0.0`)
- Manualmente (`workflow_dispatch`)

**Qué hace:**
1. Checkout con `fetch-depth: 0` (historial completo)
2. Ejecuta `git-cliff` con `cliff.toml`
3. Genera o actualiza `CHANGELOG.md`
4. Hace commit del cambio automáticamente

**Secretos requeridos:** Ninguno (usa `GITHUB_TOKEN` automático).

**Umbral de bloqueo:**
- No bloquea. Solo actualiza el CHANGELOG.

**Configuración:**
- `cliff.toml` en la raíz define el formato
- El commit automático usa `chore: update CHANGELOG.md for vX.Y.Z`

**Cómo usarlo:**
```bash
# Crear un tag
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0
```
El workflow se dispara automáticamente y actualiza `CHANGELOG.md`.

**Nota importante:** El commit automático se hace con `stefanzweifel/git-auto-commit-action@v5`. Si tu rama `main` está protegida, necesitas permitir que el bot haga push.

---

## Secrets necesarios en GitHub

| Secret | Workflow que lo usa | Obligatorio |
|--------|---------------------|-------------|
| `CODECOV_TOKEN` | `tests.yml` | Sí (para cobertura) |
| `GITHUB_TOKEN` | Todos (automático) | Automático |
| `SSH_HOST` | `deploy.yml` (si aplica) | Solo si usas deploy |
| `SSH_USER` | `deploy.yml` (si aplica) | Solo si usas deploy |
| `SSH_KEY` | `deploy.yml` (si aplica) | Solo si usas deploy |

📖 **Documentación detallada:** [`GITHUB_SECRETS.md`](GITHUB_SECRETS.md)

---

## Referencias

- [`../docs/SEGURIDAD.md`](SEGURIDAD.md) — Alineación NIST SSDF y OWASP
- [`../docs/HERRAMIENTAS_SEGURIDAD.md`](HERRAMIENTAS_SEGURIDAD.md) — Instalación de herramientas
- [`../docs/GITHUB_SECRETS.md`](GITHUB_SECRETS.md) — Configuración de secrets
- [`../docs/prompts/07-Plan-Pruebas.md`](prompts/07-Plan-Pruebas.md) — Plan de pruebas
