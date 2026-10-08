# Contribuir a plantilla-dev-ia

🌍 **Lee esto en:** [Español](CONTRIBUTING.es.md) | [English](CONTRIBUTING.md)

Gracias por tu interés en mejorar este proyecto. Esta guía explica cómo contribuir de forma efectiva.

---

## Convenciones de commits

Este proyecto usa **Conventional Commits**:

```
<tipo>(<alcance>): <descripción>
```

**Tipos válidos:** `feat`, `fix`, `security`, `docs`, `chore`, `refactor`, `test`, `perf`, `ci`, `build`, `revert`.

**Ejemplos:**

- `feat(prompts): añadir prompt para auditoría de dependencias`
- `fix(scripts): manejar rutas con espacios en init-project.sh`
- `docs(readme): añadir traducción al inglés`
- `security(gitleaks): actualizar reglas para nuevas API keys`

Los commits se validan automáticamente con el hook `commit-msg`. Si el mensaje no sigue el formato, el commit será rechazado.

---

## Flujo de trabajo

1. **Forkea** el repositorio.
2. **Crea una rama**: `git checkout -b feat/mi-mejora`.
3. **Haz tus cambios** siguiendo el estilo de código del proyecto.
4. **Verifica que pasan los hooks** (`pre-commit` y `commit-msg` se ejecutan automáticamente al commitear).
5. **Push a tu rama**: `git push origin feat/mi-mejora`.
6. **Abre un Pull Request**.

### Nombres de rama

| Tipo | Ejemplo |
|------|---------|
| Feature | `feat/añadir-workflow-deploy` |
| Corrección de bug | `fix/warning-shellcheck` |
| Documentación | `docs/actualizar-readme` |
| Seguridad | `security/actualizar-reglas-gitleaks` |
| Refactor | `refactor/script-init-project` |

---

## Requisitos de Pull Request

Todos los PRs deben pasar los siguientes checks automatizados antes de poder mergearse:

| Check | Workflow | Bloquea merge |
|-------|----------|---------------|
| Validación de estructura | `validate-template.yml` | Sí |
| Lint de Shell | `validate-template.yml` | Sí |
| Validación de configs | `validate-template.yml` | Sí |
| Test del template | `validate-template.yml` | Sí |
| Lint de Markdown | `validate-template.yml` | Informativo |

**Los 4 primeros checks deben pasar para que el PR sea mergeable.** Los problemas de markdownlint se reportan pero no bloquean el merge.

### Qué incluir en tu PR

- **Título claro** siguiendo Conventional Commits (ej. `feat(template): añadir README bilingüe`).
- **Descripción** explicando qué cambia y por qué.
- **Referencia a issues relacionados** si aplica (`Closes #123`).
- **Capturas de pantalla** si el cambio afecta la salida renderizada (docs, diagramas).

---

## Estilo de código

### Scripts shell

- Usar `#!/usr/bin/env bash` al inicio.
- `set -euo pipefail` por seguridad.
- Usar `[[ ]]` en lugar de `[ ]` para condicionales.
- Citar variables: `"$VAR"` no `$VAR`.
- Pasar ShellCheck sin warnings.

### Markdown

- Usar headings ATX (`#`, `##`, `###`) — no Setext.
- Los bloques de código deben especificar lenguaje (` ```bash `, ` ```yaml `).
- Las tablas deben estar alineadas para facilitar la lectura.
- Longitud máxima de línea: 80 caracteres (excepto tablas y URLs largas).

### YAML

- Indentación de 2 espacios.
- Sin espacios al final de línea.
- Usar `kebab-case` para claves cuando aplique.

---

## Reportar bugs

Al abrir un issue por un bug, incluye:

- **Entorno**: SO, versión de Bash, Node.js, Python.
- **Pasos para reproducir**: comandos exactos.
- **Comportamiento esperado** vs. **comportamiento actual**.
- **Logs o capturas de pantalla** si aplica.

---

## Solicitudes de funcionalidad

Al abrir un issue para pedir una funcionalidad:

- **Caso de uso**: ¿por qué se necesita esta funcionalidad?
- **Solución propuesta**: ¿cómo la implementarías?
- **Alternativas consideradas**: ¿qué otros enfoques se evaluaron?

---

## Problemas de seguridad

**No abras issues públicos para vulnerabilidades de seguridad.** En su lugar, abre un aviso privado de seguridad en GitHub:

1. Ve a la pestaña **Security**.
2. Clic en **Report a vulnerability**.
3. Proporciona una descripción detallada.

---

## Código de conducta

Sé respetuoso. No se tolera acoso, discriminación ni ataques personales.

Los desacuerdos sobre decisiones técnicas son válidos — enfócate en la idea, no en la persona.

---

## Licencia

Al contribuir, aceptas que tu contribución se licencie bajo la **MIT License**, la misma licencia que este proyecto. Ver [`LICENSE`](LICENSE) para más detalles.

---

## ¿Preguntas?

Si tienes preguntas antes de contribuir:

- Abre un issue con la etiqueta `question`.
- Revisa la documentación en [`docs/`](docs/).
- Ver [`scripts/README.md`](scripts/README.md) y [`scripts/README.es.md`](scripts/README.es.md) para ayuda específica de los scripts.

---

> **¡Gracias por contribuir!**
