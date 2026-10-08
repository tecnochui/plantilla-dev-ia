# Prompts de Documentación

🌍 **Lee esto en:** [Español](README.md) | [English](../en/README.md)

> Guía de uso de los prompts para generar la documentación fundacional del proyecto.
> Cada prompt genera **un solo documento**. Se validan secuencialmente antes de avanzar.

---

## Flujo secuencial

```
1. PRD-SRD          → ¿Qué construimos y para quién?
2. SRS              → ¿Qué requisitos funcionales y no funcionales tiene?
3. Propuesta Técnica → ¿Cómo lo vamos a construir? (stack, arquitectura, licencia)
4. SSD-TDD          → ¿Cómo está diseñado en detalle? (arquitectura, BD, API)
5. Mapeo NIST+OWASP → ¿Cómo cumplimos con seguridad?
6. Estrategia Respaldos → ¿Cómo respaldamos y retenemos?
7. Plan de Pruebas  → ¿Cómo verificamos que funciona y es seguro?
```

Cada documento depende del anterior. **No se salta ningún paso.**

---

## Tabla de referencia rápida

| # | Prompt | Depende de | Modelo recomendado | Archivos a adjuntar |
|---|--------|-----------|-------------------|---------------------|
| 1 | PRD-SRD | Nada | DeepSeek web / Gemini web | Ninguno |
| 2 | SRS | PRD-SRD | DeepSeek web | docs/PRD-SRD.md |
| 3 | Propuesta Técnica | SRS | DeepSeek web / Gemini web | docs/SRS.md |
| 4 | SSD-TDD | SRS + Propuesta | DeepSeek web | docs/SRS.md, docs/Propuesta_Tecnica.md |
| 5 | Mapeo NIST+OWASP | SSD-TDD | DeepSeek web | docs/SSD-TDD.md, docs/SRS.md |
| 6 | Estrategia Respaldos | SSD-TDD | DeepSeek web | docs/SSD-TDD.md |
| 7 | Plan de Pruebas | SSD-TDD + SRS | DeepSeek web / Gemini web | docs/SRS.md, docs/SSD-TDD.md, docs/Propuesta_Tecnica.md |
| 8 | Registro Forense | Código existente | DeepSeek vía Zoo Code | El repo completo |

**Nota sobre el Prompt 8:** Es el único que no se usa al inicio. Se usa **después** de que el código existe, cuando necesitas entender un sistema sin documentación.

---

## Reglas de uso

1. **Un prompt = un documento.** Nunca pidas dos documentos en el mismo prompt.
2. **Valida antes de avanzar.** Si el documento no te convence, itera sobre ese prompt antes de pasar al siguiente.
3. **Adjunta los archivos cuando el prompt lo indique.** Sin ellos, la IA inventa.
4. **Usa modelos web gratuitos.** Reserva Claude Sonnet vía API solo para casos críticos.
5. **Guarda el resultado** con el nombre exacto indicado en cada prompt.
6. **No regeneres desde cero** si solo necesitas corregir una sección. Pide a la IA que modifique solo esa sección.

---

## Cuándo iterar y cuándo avanzar

| Situación | Acción |
|-----------|--------|
| El documento está completo y coherente | Guardar y avanzar al siguiente |
| Falta detalle en 1-2 secciones | Pedir a la IA que expanda esas secciones |
| El documento es genérico (no específico del proyecto) | Regenerar con más contexto en el prompt |
| El documento contradice un requisito del SRS | Regenerar la sección conflictiva |
| El documento inventa cosas que no le dijiste | Corregir con "no inventes, pregunta si falta contexto" |

---

## Modelos recomendados por tipo de tarea

| Tarea | Modelo | Razón |
|-------|--------|-------|
| Documentos cortos y estructurados (PRD, SRS) | DeepSeek web | Rápido, preciso, sin límite diario |
| Documentos largos con análisis (Propuesta, SSD) | Gemini web | Mejor manejo de contexto largo |
| Documentos con decisiones críticas de seguridad | Claude web | Mejor razonamiento en seguridad |
| Prompts y validación de outputs | DeepSeek web | Consistente y sin límites |

---

## Convenciones

- **Idioma:** español (excepto términos técnicos que van en inglés: JWT, API, etc.).
- **Formato:** Markdown con tablas, checkboxes y bloques de código.
- **Longitud esperada:** 300-500 líneas para documentos con análisis; 100-200 para documentos operativos.
- **Diagramas:** Mermaid cuando aporte claridad (arquitectura, flujos, BD).
- **Código:** nunca generar código en estos documentos; solo decisiones de diseño.

---

## Estructura de archivos resultante

```
docs/
├── PRD-SRD.md
├── SRS.md
├── Propuesta_Tecnica.md
├── SSD-TDD.md
├── Mapeo_NIST_OWASP.md
├── Estrategia_Respaldos.md
├── Plan_Pruebas.md
├── REGISTRO_FORENSE.md
└── prompts/
    ├── README.md              ← Este archivo
    ├── 01-PRD-SRD.md
    ├── 02-SRS.md
    ├── 03-Propuesta-Tecnica.md
    ├── 04-SSD-TDD.md
    ├── 05-Mapeo-NIST-OWASP.md
    ├── 06-Estrategia-Respaldos.md
    ├── 07-Plan-Pruebas.md
    └── 08-Registro-Forense.md
```

---

## Cómo usar un prompt (paso a paso)

1. Abrir `docs/prompts/0X-Nombre.md`.
2. Copiar **todo el contenido** del bloque "Prompt completo".
3. Abrir la web del modelo recomendado.
4. Adjuntar los archivos indicados en la sección "Archivos a adjuntar".
5. Pegar el prompt.
6. Esperar la respuesta.
7. Validar con la sección "Validación post-generación" del propio archivo.
8. Guardar el resultado en `docs/Nombre.md`.
9. Avanzar al siguiente prompt.