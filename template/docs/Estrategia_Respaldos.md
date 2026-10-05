# Estrategia de Respaldos y Retención de Logs

> **Estado:** Pendiente de redacción.
> **Instrucciones:** Usar el Prompt 6 (`docs/prompts/06-Estrategia-Respaldos.md`) con DeepSeek web.
> **Depende de:** `docs/SSD-TDD.md`

---

## 1. Activos a respaldar

| Activo | Descripción | Criticidad |
|--------|-------------|------------|
| Código fuente | Repositorio Git | Alta |
| Base de datos | Datos de producción | Alta |
| Configuraciones | Archivos de config (sin secretos) | Media |
| Logs | Registros de aplicación y seguridad | Media |
| Documentación | Documentos en `docs/` | Media |

## 2. Frecuencia de respaldo

| Activo | Frecuencia | Destino | Retención |
|--------|-----------|---------|-----------|
| Código fuente | Cada push | GitHub | Permanente |
| Base de datos | [Diario/Semanal] | [Destino] | [30 días] |
| Configuraciones | [Semanal] | [Destino] | [90 días] |
| Logs | [Continuo] | [Destino] | [90 días] |

## 3. Destino de respaldo

### 3.1. Local
- **Ruta:** [ej. `/var/backups/mi-app/`]
- **Formato:** [ej. `.tar.gz`, `.sql.gz`]
- **Cifrado:** [Sí/No, con qué]

### 3.2. Nube
- **Proveedor:** [ej. Backblaze B2, S3, etc.]
- **Bucket:** [nombre]
- **Cifrado:** [Sí/No, con qué]

### 3.3. Git remoto
- **Repositorio:** [URL]
- **Qué se versiona:** Código, documentación, configuración (sin secretos)
- **Qué NO se versiona:** `.env`, credenciales, datos de producción

## 4. Regla 3-2-1

- **3 copias:** [Código en local + GitHub + espejo]
- **2 medios:** [SSD + nube, o disco externo + nube]
- **1 fuera del sitio:** [Nube, o disco externo en otra ubicación]

## 5. Retención

| Tipo de respaldo | Retención | Compresión | Eliminación |
|------------------|-----------|------------|-------------|
| Diario | 30 días | Después de 7 días | Automática |
| Semanal | 90 días | Después de 30 días | Automática |
| Mensual | 1 año | Inmediata | Automática |
| Anual | 5 años | Inmediata | Manual |

## 6. Retención de logs

| Tipo de log | Retención | Formato | Rotación |
|-------------|-----------|---------|----------|
| Aplicación | [30 días] | [JSON/Texto] | [Diaria] |
| Acceso | [90 días] | [Common Log Format] | [Diaria] |
| Seguridad | [≥ 90 días] | [JSON] | [Diaria] |
| Errores | [90 días] | [JSON] | [Diaria] |

**Nota:** Los logs de seguridad **nunca deben contener** datos sensibles (PII, contraseñas, tokens).

## 7. Procedimiento de restauración

### Restaurar código
```bash
git clone [url]
cd [proyecto]
git checkout [tag o commit]
```

### Restaurar base de datos
```bash
# [Comando específico del motor]
pg_restore -d [db] [backup.dump]
```

### Restaurar configuración
```bash
tar -xzf [backup.tar.gz] -C [destino]
```

### Verificación post-restauración
- [ ] El código clona sin errores.
- [ ] La BD restaura sin errores.
- [ ] La aplicación inicia correctamente.
- [ ] Los tests pasan.

## 8. Verificación de respaldos

| Prueba | Frecuencia | Responsable |
|--------|-----------|-------------|
| Restauración de código | [Mensual] | [Tú] |
| Restauración de BD | [Mensual] | [Tú] |
| Verificación de integridad | [Semanal] | [Automático] |

## 9. Automatización

### Script de respaldo de BD (ejemplo)
```bash
#!/usr/bin/env bash
# backup-db.sh
set -euo pipefail

FECHA=$(date +%Y%m%d_%H%M%S)
DESTINO="/var/backups/mi-app/db"
mkdir -p "$DESTINO"

pg_dump -Fc mi_db > "$DESTINO/mi_db_$FECHA.dump"
gzip "$DESTINO/mi_db_$FECHA.dump"

# Eliminar respaldos de más de 30 días
find "$DESTINO" -name "*.dump.gz" -mtime +30 -delete

echo "Respaldo completado: mi_db_$FECHA.dump.gz"
```

### Cron job
```cron
# Respaldo diario a las 3 AM
0 3 * * * /usr/local/bin/backup-db.sh >> /var/log/backup.log 2>&1
```
