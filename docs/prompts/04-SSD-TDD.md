# Prompt 4 — SSD-TDD (Software Design Document + Technical Design Document)

## Propósito
Diseño detallado: arquitectura de módulos, esquema de BD, contratos de API, decisiones de seguridad.

## Modelo recomendado
DeepSeek web.

## Archivos a adjuntar
`docs/SRS.md` + `docs/Propuesta_Tecnica.md`

## Cuándo usarlo
Después de que la Propuesta Técnica esté validada.

---

## Prompt completo

```
Con base en el SRS y la Propuesta Técnica adjuntos, genera el SSD-TDD (Software Design Document + Technical Design Document).

Secciones requeridas:

1. Arquitectura detallada
   - Diagrama de componentes (Mermaid)
   - Capas de la aplicación (presentación, lógica, datos)
   - Patrones de diseño aplicados (MVC, Repository, CQRS, etc.)
   - Justificación de cada patrón

2. Diseño de base de datos
   - Diagrama Entidad-Relación (Mermaid erDiagram)
   - Tablas: nombre, columnas, tipos, constraints
   - Índices recomendados
   - Relaciones (1:1, 1:N, N:M)
   - Estrategia de migraciones (Alembic, Flyway, etc.)
   - Estrategia de backups (a nivel de BD)

3. Diseño de API
   - Endpoints: método, ruta, descripción
   - Contratos de entrada (request body, query params)
   - Contratos de salida (response body)
   - Códigos de error y su significado
   - Autenticación y autorización por endpoint
   - Rate limiting por endpoint

4. Diagramas
   - Componentes (Mermaid)
   - Secuencia para flujos críticos (login, pago, etc.)
   - Estados para entidades con máquina de estados
   - ER de base de datos

5. Decisiones de seguridad en el diseño
   - Autenticación: JWT, OAuth2, sesiones
   - Autorización: RBAC, ABAC, ACL
   - Cifrado: en tránsito (TLS), en reposo (AES-256)
   - Gestión de secretos: .env, vault, KMS
   - Validación de inputs: sanitización, whitelisting
   - Logging seguro: qué NO loguear (PII, secretos)

6. Estrategia de testing (resumen)
   > Nota: el detalle completo está en `docs/Plan_Pruebas.md`.
   - Pirámide de pruebas (unitarias, integración, E2E)
   - Herramientas por nivel
   - Umbral de cobertura

Reglas:
- Usa diagramas Mermaid para que Zoo Code los renderice en VS Code.
- No generes código. Solo diseño.
- Si falta información, hazme preguntas antes de inventar.
- Sé específico en los contratos de API (usa JSON de ejemplo).
- Longitud esperada: 500-800 líneas.
```

---

## Validación post-generación

- [ ] El diagrama ER cubre todas las entidades del SRS.
- [ ] Cada endpoint tiene contrato de entrada y salida documentado.
- [ ] La sección de seguridad cubre los 10 puntos del OWASP Top 10:2025.
- [ ] Los diagramas Mermaid son válidos (renderizan sin errores).
- [ ] La sección 6 referencia a `Plan_Pruebas.md` (no duplica).

## Guardar como
`docs/SSD-TDD.md`
