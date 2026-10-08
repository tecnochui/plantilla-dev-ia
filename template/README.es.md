# [NOMBRE DEL PROYECTO]

🌍 **Lee esto en:** [Español](README.es.md) | [English](README.md)

> [Descripción breve de una línea]

## Estado
[En desarrollo / Beta / Estable]

## Requisitos
- [Lenguaje] [versión]
- [Dependencias principales]

## Instalación
```bash
# Clonar
git clone [url]

# Instalar dependencias
npm install        # Node.js
pip install -r requirements.txt  # Python
```

## Uso
```bash
# Desarrollo
make help
```

## Tests
```bash
make test
```

## Seguridad
Este proyecto sigue prácticas alineadas con OWASP Top 10:2025 y NIST SSDF.
- SAST: Semgrep
- SCA: Trivy
- Secrets: Gitleaks + detect-secrets
- DAST: OWASP ZAP (staging)

📖 Ver [`docs/WORKFLOWS.md`](docs/WORKFLOWS.md) para detalles.

## Documentación
- [PRD-SRD](docs/PRD-SRD.md)
- [SRS](docs/SRS.md)
- [SSD-TDD](docs/SSD-TDD.md)
- [Plan de Pruebas](docs/Plan_Pruebas.md)
- [Registro Forense](docs/REGISTRO_FORENSE.md) (solo si aplica)
- [Workflows de CI/CD](docs/WORKFLOWS.md)
- [Herramientas de seguridad](docs/HERRAMIENTAS_SEGURIDAD.md)
- [Secrets de GitHub](docs/GITHUB_SECRETS.md)
- [Prompts de documentación](docs/prompts/README.md)

## Licencia
[Pendiente: definir al inicio del proyecto]
