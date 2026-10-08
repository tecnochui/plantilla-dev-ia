# Prompt 5 — Mapeo NIST SSDF + OWASP Top 10:2025

🌍 **Lee esto en:** [Español](05-Mapeo-NIST-OWASP.md) | [English](../en/05-NIST-OWASP-Mapping.md)

## Propósito
Documentar cómo el proyecto cumple con prácticas de seguridad reconocidas.

## Modelo recomendado
DeepSeek web o Claude web (si necesitas razonamiento profundo de seguridad).

## Archivos a adjuntar
`docs/SSD-TDD.md` + `docs/SRS.md`

## Cuándo usarlo
Después de que el SSD-TDD esté validado.

---

## Prompt completo

```
Con base en el SRS y el SSD-TDD adjuntos, genera el documento de cumplimiento de seguridad para este proyecto.

IMPORTANTE: Este proyecto es desarrollado por un individuo, no por una organización. No apunta a certificación. Documenta solo las prácticas aplicables.

Secciones requeridas:

1. Mapeo NIST SSDF (SP 800-218)
   Para cada una de las siguientes prácticas, indica:
   - Cómo se aplica en este proyecto
   - Qué herramienta se usa
   - Cada cuánto se ejecuta
   - Quién es responsable

   Prácticas:
   - PO.1: Definir requisitos de seguridad
   - PO.3: Controlar el toolchain
   - PS.1: Proteger el código
   - PS.2: Verificar integridad de componentes
   - PW.1: Threat modeling
   - PW.4: Verificar componentes de terceros
   - PW.7: Revisión de código
   - RV.1: Identificar vulnerabilidades
   - RV.2: Evaluar y remediar

   Al final, lista explícitamente qué prácticas NO aplican y por qué.

2. Mapeo OWASP Top 10:2025
   Para cada categoría, indica:
   - ¿Aplica al proyecto? (Sí/No)
   - Cómo se mitiga
   - Qué prueba lo verifica

   Categorías:
   - A01: Broken Access Control
   - A02: Security Misconfiguration
   - A03: Software Supply Chain Failures
   - A04: Cryptographic Failures
   - A05: Injection
   - A06: Insecure Design
   - A07: Authentication Failures
   - A08: Software or Data Integrity Failures
   - A09: Security Logging & Alerting Failures
   - A10: Mishandling of Exceptional Conditions

3. Herramientas de seguridad del proyecto
   Tabla con: herramienta, tipo (SAST/SCA/DAST), workflow de CI, umbral de bloqueo.

4. Matriz de trazabilidad de seguridad
   Tabla: requisito de seguridad (SRS) → práctica NIST → categoría OWASP → prueba que verifica.

5. Excepciones y omisiones
   Lista de prácticas NIST/OWASP que NO se implementan, con justificación.

Reglas:
- Sé honesto: si algo no se implementa, dilo y justifica.
- No inventes cumplimiento que no existe.
- Si falta información, hazme preguntas.
- Usa formato Markdown con tablas.
- Longitud esperada: 300-400 líneas.
```

---

## Validación post-generación

- [ ] Cada práctica NIST aplicable tiene herramienta y frecuencia.
- [ ] Las prácticas omitidas tienen justificación explícita.
- [ ] Las 10 categorías OWASP están cubiertas (aplican o no, con razón).
- [ ] La matriz de trazabilidad conecta SRS → NIST → OWASP → prueba.
- [ ] Las herramientas coinciden con las del Plan de Pruebas.

## Qué hacer si la salida no cumple

| Problema | Acción |
|----------|--------|
| Inventa cumplimiento que no existe | Corregir con "sé honesto: si algo no se implementa, dilo y justifica" |
| Falta alguna práctica NIST | Pedir "cubre las 9 prácticas NIST listadas, aunque sea para marcarlas como no aplicables" |
| Falta alguna categoría OWASP | Pedir "cubre las 10 categorías, con Sí/No y razón en cada una" |
| La matriz de trazabilidad está incompleta | Pedir "conecta cada requisito de seguridad del SRS con NIST, OWASP y prueba" |
| Herramientas no coinciden con el Plan de Pruebas | Corregir con "usa exactamente las herramientas del Plan de Pruebas" |

## Guardar como
`docs/Mapeo_NIST_OWASP.md`
