# Prompt 2 — SRS (Software Requirements Specification)

🌍 **Lee esto en:** [Español](02-SRS.md) | [English](../en/02-SRS.md)

## Propósito
Detallar los requisitos funcionales y no funcionales del sistema, con trazabilidad al PRD-SRD.

## Modelo recomendado
DeepSeek web.

## Archivos a adjuntar
`docs/PRD-SRD.md`

## Cuándo usarlo
Después de que el PRD-SRD esté validado y aprobado.

---

## Prompt completo

```
Con base en el PRD-SRD adjunto, genera el SRS (Software Requirements Specification) siguiendo el estándar IEEE 830 / ISO 29148.

Secciones requeridas:

1. Introducción
   - Propósito
   - Alcance
   - Definiciones, acrónimos y abreviaturas
   - Referencias

2. Descripción general
   - Perspectiva del producto
   - Funciones principales
   - Usuarios objetivo
   - Restricciones generales
   - Supuestos y dependencias

3. Requisitos funcionales
   - Numerados (RF-001, RF-002, ...)
   - Cada uno con: descripción, prioridad (Alta/Media/Baja), criterios de aceptación
   - Trazabilidad: cada RF debe mapear a una historia de usuario del PRD-SRD

4. Requisitos no funcionales
   - Rendimiento (tiempos de respuesta, throughput)
   - Seguridad (autenticación, autorización, cifrado)
   - Usabilidad (accesibilidad, idiomas)
   - Disponibilidad (uptime esperado, tolerancia a fallos)
   - Mantenibilidad (cobertura de tests, documentación)
   - Portabilidad (sistemas operativos, navegadores)

5. Interfaces externas
   - Interfaces de usuario
   - Interfaces de hardware
   - Interfaces de software (APIs de terceros)
   - Interfaces de comunicación (protocolos)

6. Restricciones de diseño
   - Restricciones técnicas
   - Restricciones regulatorias
   - Restricciones de negocio

7. Matriz de trazabilidad
   - Tabla: historia de usuario (PRD-SRD) → requisito funcional (SRS)

Reglas:
- Sé explícito en los límites. Cada requisito debe ser verificable.
- Si falta información, hazme preguntas antes de inventar.
- No generes decisiones técnicas (stack, framework). Solo requisitos.
- No generes código.
- Usa formato Markdown con tablas y checkboxes.
- Longitud esperada: 400-600 líneas.
```

---

## Validación post-generación

- [ ] Cada requisito funcional tiene ID único (RF-001, RF-002...).
- [ ] Cada requisito no funcional tiene métrica (no "rápido", sino "< 200ms").
- [ ] La matriz de trazabilidad cubre todas las historias de usuario del PRD-SRD.
- [ ] Los requisitos están priorizados (Alta/Media/Baja).
- [ ] Las interfaces externas listan protocolos concretos (REST, gRPC, WebSocket).

## Qué hacer si la salida no cumple

| Problema | Acción |
|----------|--------|
| Requisitos genéricos | Añadir más contexto al PRD-SRD y regenerar |
| Requisitos no medibles | Pedir "cada requisito debe tener una métrica verificable" |
| Falta la matriz de trazabilidad | Pedir "genera la matriz completa PRD-SRD → SRS" |
| No hay priorización | Pedir "asigna prioridad Alta/Media/Baja a cada RF" |
| Contradice el PRD-SRD | Regenerar la sección conflictiva |

## Guardar como
`docs/SRS.md`
