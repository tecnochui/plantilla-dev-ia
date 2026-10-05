# Prompt 6 — Estrategia de Respaldos y Retención de Logs

## Propósito
Definir cómo se respaldan los activos del proyecto y cuánto tiempo se retienen los logs.

## Modelo recomendado
DeepSeek web.

## Archivos a adjuntar
`docs/SSD-TDD.md`

## Cuándo usarlo
Después de que el SSD-TDD esté validado.

---

## Prompt completo

```
Con base en el SSD-TDD adjunto, genera la Estrategia de Respaldos y Retención de Logs para este proyecto.

Antes de empezar, hazme estas preguntas:

1. ¿Dónde quieres almacenar los respaldos? (local, nube, git remoto, mixto)
2. ¿Cuánto tiempo quieres retener logs de aplicación? (días, semanas, meses)
3. ¿Cuánto tiempo quieres retener logs de seguridad? (recomendación: mínimo 90 días)
4. ¿Tienes presupuesto para almacenamiento en nube? (si no, solo local)

Con mis respuestas, genera:

1. Activos a respaldar
   - Código fuente
   - Base de datos
   - Configuraciones
   - Logs
   - Documentación
   - Secretos (¿se respaldan? ¿cómo?)

2. Frecuencia de respaldo por activo
   - Tabla: activo → frecuencia → destino → retención

3. Destino de respaldo
   - Local: rutas concretas
   - Nube: proveedor, bucket, cifrado
   - Git remoto: qué se versiona y qué no

4. Regla 3-2-1 aplicada
   - 3 copias de los datos
   - 2 medios diferentes
   - 1 copia fuera del sitio

5. Retención
   - Cuánto tiempo guardar cada tipo de respaldo
   - Cuándo comprimir (ej. después de 30 días)
   - Cuándo eliminar (ej. después de 1 año)

6. Retención de logs
   - Logs de aplicación: cuánto tiempo, qué formato
   - Logs de acceso: cuánto tiempo
   - Logs de seguridad: cuánto tiempo (mínimo 90 días)
   - Rotación: cuándo y cómo

7. Procedimiento de restauración
   - Paso a paso para restaurar desde respaldo
   - Verificación post-restauración

8. Verificación de respaldos
   - Cómo probar que los respaldos son restaurables
   - Frecuencia de pruebas de restauración

9. Automatización
   - Scripts o cron jobs necesarios
   - Herramientas (rsync, restic, borgbackup, etc.)

Reglas:
- Sé específico en rutas, comandos y frecuencias.
- Incluye scripts de ejemplo (bash) para los respaldos.
- Si falta información, hazme preguntas.
- Longitud esperada: 200-300 líneas.
```

---

## Validación post-generación

- [ ] La regla 3-2-1 está aplicada con destinos concretos.
- [ ] Cada activo tiene frecuencia y retención definidas.
- [ ] El procedimiento de restauración es paso a paso.
- [ ] Los scripts de respaldo son ejecutables (bash válido).
- [ ] La retención de logs de seguridad es ≥ 90 días.

## Guardar como
`docs/Estrategia_Respaldos.md`
