# Prompt 1 — PRD-SRD (Documento de Requisitos del Producto y Software)

🌍 **Lee esto en:** [Español](01-PRD-SRD.md) | [English](../en/01-PRD-SRD.md)

## Propósito
Definir **qué** se va a construir y **para quién**, antes de decidir **cómo**.

## Modelo recomendado
DeepSeek web o Gemini web (gratuitos).

## Archivos a adjuntar
Ninguno.

## Cuándo usarlo
Al inicio de un proyecto nuevo, cuando el cliente/usuario describe qué quiere pero no hay documentación previa.

---

## Prompt completo

```
Actúa como analista de producto y requisitos. Voy a construir un sistema llamado [NOMBRE].

Contexto del negocio:
- Problema que resuelve: [describe el problema]
- Usuarios que lo usarán: [quiénes son]
- Valor que aporta: [por qué es útil]

Alcance inicial:
- SÍ incluye: [lista de funcionalidades incluidas]
- NO incluye: [lista de funcionalidades excluidas explícitamente]

Genera el PRD-SRD con estas secciones:

1. Resumen ejecutivo (3-5 líneas)
2. Objetivos y métricas de éxito
3. Usuarios objetivo (personas)
4. Historias de usuario con criterios de aceptación
5. Alcance: incluido / excluido
6. Restricciones y supuestos
7. Riesgos iniciales

Reglas:
- No generes código ni decisiones técnicas (stack, lenguajes, frameworks).
- Sé específico y concreto. Evita generalidades como "el sistema debe ser rápido".
- Si falta información para alguna sección, hazme preguntas ANTES de inventar.
- Usa formato Markdown con tablas y checkboxes.
- Longitud esperada: 200-400 líneas.

Al final, incluye una sección "Preguntas pendientes" con todo lo que necesitas aclarar antes de continuar.
```

---

## Validación post-generación

- [ ] El resumen ejecutivo explica el proyecto en 3-5 líneas sin jerga técnica.
- [ ] Los objetivos son medibles (no "ser rápido", sino "responder en < 200ms").
- [ ] Las historias de usuario siguen el formato "Como [rol], quiero [acción] para [beneficio]".
- [ ] Los criterios de aceptación son verificables (no "funciona bien").
- [ ] El alcance excluido está explícito (evita scope creep).
- [ ] Los riesgos tienen probabilidad e impacto estimados.

## Qué hacer si la salida no cumple

| Problema | Acción |
|----------|--------|
| Es genérico | Añadir más contexto al prompt y regenerar |
| Inventa funcionalidades | Corregir con "no incluyas funciones que no mencioné" |
| Falta una sección | Pedir "expande la sección X con más detalle" |
| Muy largo | Pedir "reduce a lo esencial, elimina redundancia" |

## Guardar como
`docs/PRD-SRD.md`
