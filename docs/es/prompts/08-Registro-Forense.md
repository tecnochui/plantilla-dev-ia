# Prompt 8 — Registro Forense (Ingeniería Inversa)

🌍 **Lee esto en:** [Español](08-Registro-Forense.md) | [English](../en/08-Forensic-Record.md)

## Propósito
Generar `docs/REGISTRO_FORENSE.md` a partir del análisis de un sistema sin documentación (propio o de terceros).

## Modelo recomendado
DeepSeek V4 Flash vía Zoo Code (modo Architect).

## Archivos a adjuntar
- El código fuente del sistema (vía Zoo Code, que puede leer el repo completo)
- Si existe, cualquier documentación previa (README.md, comentarios)

## Cuándo usarlo
**Después** de que el código existe. Es el único prompt que no se usa al inicio del proyecto.
Se usa cuando:
- Heredas un proyecto sin documentación.
- Retomas un proyecto tuyo antiguo que nunca documentaste.
- Necesitas modificar un sistema de terceros que no entiendes.

## Diferencia con los otros prompts

| Aspecto | Prompts 1-7 | Prompt 8 |
|---------|-------------|----------|
| **Cuándo** | Al inicio, antes de codificar | Cuando ya existe código |
| **Qué produce** | Documentos de diseño (a futuro) | Registro de hallazgos (a pasado) |
| **Modelo** | DeepSeek web / Gemini web | DeepSeek vía Zoo Code (necesita leer archivos) |
| **Iteración** | Se valida y avanza | Se actualiza continuamente |

---

## Prompt completo

```
Actúa como ingeniero de software forense. Necesito que analices este sistema sin documentación y generes un Registro Forense que documente lo que descubras.

Contexto:
- Tipo de sistema: [web / API / script / escritorio / mixto]
- Origen: [propio sin docs / terceros / desconocido]
- Mi objetivo: [qué necesito hacer con este sistema]
- Tiempo disponible: [urgencia del análisis]

Proceso de análisis (sigue este orden):

1. INVENTARIO
   - Lista todos los directorios y archivos relevantes
   - Para cada uno, indica: tipo, propósito inferido, confianza (Alta/Media/Baja)
   - Ignora node_modules/, venv/, dist/, build/, .git/

2. FLUJO DE DATOS
   - Dibuja un diagrama Mermaid con el flujo principal
   - Identifica entradas, transformaciones y salidas
   - Marca los puntos donde hay interacción con el exterior

3. PUNTOS DE ENTRADA
   - Lista todos los puntos por donde el sistema recibe input
   - Para cada uno: protocolo, puerto, autenticación, notas
   - Incluye endpoints HTTP, comandos CLI, cron jobs, webhooks

4. DEPENDENCIAS EXTERNAS
   - Lista las dependencias críticas
   - Para cada una: versión, tipo, riesgo detectado
   - Verifica vulnerabilidades conocidas si es posible

5. ESQUEMA DE BASE DE DATOS
   - Si hay BD, dibuja el diagrama ER en Mermaid
   - Lista tablas, columnas, relaciones
   - Indica si faltan índices o foreign keys

6. ZONAS OSCURAS
   - Lista lo que NO pudiste entender
   - Para cada zona: archivo/módulo, por qué no se entiende, qué se necesita para entenderlo

7. PENDIENTES DE VERIFICACIÓN
   - Lista acciones concretas para completar el análisis
   - Prioriza por impacto

8. HALLAZGOS DE SEGURIDAD
   - Primera pasada: secretos hardcodeados, endpoints sin auth, logs con PII
   - Clasifica por severidad (Alta/Media/Baja)
   - Sugiere acción para cada hallazgo

Reglas:
- NO inventes. Si no entiendes algo, márcalo como "zona oscura".
- Sé específico en rutas y nombres de archivo.
- Usa Mermaid para diagramas (flowchart y erDiagram).
- Marca cada hallazgo con fecha para historial.
- Al final, incluye una sección "Instrucciones para futuras sesiones de IA" con reglas para que otra sesión pueda continuar el análisis.
- Longitud esperada: 200-500 líneas (depende del tamaño del sistema).

Formato de salida: Markdown siguiendo la plantilla de docs/REGISTRO_FORENSE.md.
```

---

## Validación post-generación

- [ ] El inventario cubre todos los directorios relevantes (excluyendo los ignorados).
- [ ] El diagrama de flujo es coherente con los puntos de entrada.
- [ ] Las zonas oscuras están marcadas como checkboxes sin resolver.
- [ ] Los hallazgos de seguridad tienen severidad y acción sugerida.
- [ ] La sección "Instrucciones para futuras sesiones" explica cómo actualizar el registro.

## Cómo usar el registro generado

1. **Guardar** el resultado en `docs/REGISTRO_FORENSE.md`.
2. **Commitear** con `docs(forense): análisis inicial de [nombre]`.
3. **En cada sesión futura de IA**, verificar que `AGENTS.md` instruya a leer el registro antes de modificar código.
4. **Actualizar** el registro cuando:
   - Se resuelve una zona oscura → marcarla como resuelta.
   - Se completa un pendiente → marcarlo como completado.
   - Se encuentra un nuevo hallazgo → añadirlo con fecha.
   - Se modifica un módulo → actualizar su entrada en el inventario.

## Qué hacer si la salida no cumple

| Problema | Acción |
|----------|--------|
| Inventa cosas que no puede verificar | Corregir con "si no entiendes algo, márcalo como zona oscura, no inventes" |
| No usa diagramas Mermaid | Pedir "genera el flowchart del flujo de datos y el erDiagram de la BD" |
| Faltan zonas oscuras | Pedir "lista explícitamente todo lo que no pudiste entender y qué se necesita para entenderlo" |
| Hallazgos de seguridad sin severidad | Pedir "clasifica cada hallazgo por severidad (Alta/Media/Baja) y sugiere acción" |
| No incluye instrucciones para futuras sesiones | Pedir "añade la sección de instrucciones para que otra sesión de IA continúe el análisis" |

## Iteración

El Registro Forense **no es un documento de una sola vez.** Es vivo. Se actualiza con cada sesión de análisis. La sección 10 (Historial) registra cada actualización.

## Guardar como
`docs/REGISTRO_FORENSE.md`
