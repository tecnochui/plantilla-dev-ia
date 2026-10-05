# Prompt 3 — Propuesta Técnica

## Propósito
Decidir **cómo** se construirá el sistema: stack, arquitectura de alto nivel, estrategia de licenciamiento.

## Modelo recomendado
DeepSeek web o Gemini web.

## Archivos a adjuntar
`docs/SRS.md`

## Cuándo usarlo
Después de que el SRS esté validado.

---

## Prompt completo

```
Con base en el SRS adjunto, genera la Propuesta Técnica para este proyecto.

Antes de empezar, hazme estas preguntas:

1. ¿El sistema será 100% free/open source, 100% privativo, o un modelo community + versión paga?
2. ¿Tienes preferencia por algún lenguaje o framework? (si no, recomienda)
3. ¿El sistema debe correr en algún entorno específico? (Linux, Windows, web, contenedores)
4. ¿Hay restricciones de presupuesto para infraestructura? (ej. $0, $10/mes)

Con mis respuestas, genera:

1. Stack tecnológico recomendado
   - Lenguaje(s) de programación
   - Framework(s) backend
   - Framework(s) frontend (si aplica)
   - Base de datos
   - Infraestructura (local, contenedores, nube)
   - CI/CD

2. Justificación de cada elección
   - Para cada tecnología, compara con 2 alternativas
   - Explica por qué se eligió esta y no las otras
   - Menciona trade-offs (rendimiento, curva de aprendizaje, mantenimiento)

3. Arquitectura de alto nivel
   - Diagrama Mermaid (flowchart o C4)
   - Componentes principales
   - Flujo de datos entre componentes

4. Estrategia de despliegue
   - Cómo se despliega en desarrollo
   - Cómo se despliega en producción
   - Estrategia de rollback

5. Estrategia de licenciamiento
   - Con base en mi respuesta, recomienda licencias para el proyecto
   - Lista dependencias compatibles con esa licencia
   - Alerta sobre dependencias incompatibles (ej. GPL en proyecto propietario)

6. Riesgos técnicos y mitigaciones
   - Tabla: riesgo → probabilidad → impacto → mitigación

Reglas:
- No generes código. Solo decisiones técnicas justificadas.
- Si falta información, hazme preguntas antes de inventar.
- Usa diagramas Mermaid para arquitectura.
- Longitud esperada: 300-500 líneas.
```

---

## Validación post-generación

- [ ] Cada tecnología elegida tiene justificación con alternativas comparadas.
- [ ] La arquitectura tiene diagrama Mermaid.
- [ ] La estrategia de licenciamiento es coherente con el modelo elegido.
- [ ] Las dependencias recomendadas no tienen conflictos de licencia.
- [ ] Los riesgos técnicos tienen mitigación concreta.

## Guardar como
`docs/Propuesta_Tecnica.md`
