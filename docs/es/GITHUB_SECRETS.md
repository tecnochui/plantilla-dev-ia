# Secrets de GitHub

> Guía para configurar los secrets necesarios en GitHub Actions.
> Los secrets se cifran en reposo y solo se exponen a los workflows autorizados.

---

## Cómo añadir un secret

1. Ir al repositorio en GitHub.
2. **Settings** → **Secrets and variables** → **Actions**.
3. Clic en **New repository secret**.
4. Nombre: (ver tabla abajo). Valor: (el secret real).
5. Clic en **Add secret**.

**No se pueden leer de vuelta.** Si pierdes el valor, hay que rotarlo.

---

## Secrets del proyecto

### `CODECOV_TOKEN`

| Campo | Valor |
|-------|-------|
| **Nombre** | `CODECOV_TOKEN` |
| **Workflow que lo usa** | `tests.yml` |
| **Obligatorio** | Sí (para cobertura) |
| **Dónde se obtiene** | [codecov.io](https://about.codecov.io/) → Registrar repo → Settings → Repository Upload Token |
| **Cómo rotarlo** | Regenerar en Codecov y actualizar en GitHub |
| **Frecuencia de rotación** | Cada 6 meses o si se filtra |

**Cómo obtenerlo:**
1. Ir a [codecov.io](https://about.codecov.io/) y crear cuenta (gratis para repos públicos).
2. Conectar con GitHub.
3. Seleccionar el repositorio.
4. Copiar el **Repository Upload Token**.
5. Añadirlo como secret en GitHub con el nombre `CODECOV_TOKEN`.

---

### `SSH_HOST`, `SSH_USER`, `SSH_KEY` (solo si usas deploy)

| Campo | Valor |
|-------|-------|
| **Nombre** | `SSH_HOST` |
| **Workflow que lo usa** | `deploy.yml` (si está activado) |
| **Obligatorio** | Solo si usas deploy a VPS |
| **Dónde se obtiene** | IP o dominio del servidor |
| **Ejemplo** | `203.0.113.42` o `mi-servidor.com` |

| Campo | Valor |
|-------|-------|
| **Nombre** | `SSH_USER` |
| **Workflow que lo usa** | `deploy.yml` |
| **Obligatorio** | Solo si usas deploy a VPS |
| **Dónde se obtiene** | Usuario del servidor (ej. `deploy`, `ubuntu`) |
| **Ejemplo** | `deploy` |

| Campo | Valor |
|-------|-------|
| **Nombre** | `SSH_KEY` |
| **Workflow que lo usa** | `deploy.yml` |
| **Obligatorio** | Solo si usas deploy a VPS |
| **Dónde se obtiene** | Clave privada SSH (sin passphrase) del servidor |
| **Cómo rotarlo** | Generar nueva clave, actualizar `authorized_keys` en el servidor, actualizar secret en GitHub |
| **Frecuencia de rotación** | Cada 6 meses |

**Cómo generar la clave SSH:**

```bash
# En tu máquina local
ssh-keygen -t ed25519 -C "github-actions-deploy" -f ~/.ssh/deploy_key -N ""

# Copiar la clave pública al servidor
ssh-copy-id -i ~/.ssh/deploy_key.pub deploy@tu-servidor.com

# Copiar el contenido de la clave privada al secret SSH_KEY
cat ~/.ssh/deploy_key
```

**Advertencia:** La clave privada debe incluir las líneas `-----BEGIN OPENSSH PRIVATE KEY-----` y `-----END OPENSSH PRIVATE KEY-----`.

---

### `GITHUB_TOKEN`

| Campo | Valor |
|-------|-------|
| **Nombre** | `GITHUB_TOKEN` |
| **Workflow que lo usa** | Todos |
| **Obligatorio** | Automático |
| **Dónde se obtiene** | GitHub lo provee automáticamente |
| **Cómo rotarlo** | GitHub lo rota por ti |
| **Frecuencia de rotación** | Automática |

**No necesita configuración manual.** GitHub Actions inyecta este token en cada workflow que lo declare en `permissions`.

---

## Secrets opcionales (según destino de deploy)

Si usas alguna de las plantillas de `docs/deploy.yml.example`, necesitas los secrets correspondientes:

| Destino | Secrets necesarios |
|---------|-------------------|
| **VPS propio** | `SSH_HOST`, `SSH_USER`, `SSH_KEY` |
| **Vercel** | `VERCEL_TOKEN`, `VERCEL_ORG_ID`, `VERCEL_PROJECT_ID` |
| **Docker Hub + VPS** | `DOCKER_USERNAME`, `DOCKER_TOKEN`, `SSH_HOST`, `SSH_USER`, `SSH_KEY` |
| **GitHub Pages** | Ninguno (usa `GITHUB_TOKEN`) |
| **Servidor casero (Cloudflare)** | `CLOUDFLARE_TOKEN`, `SSH_HOST`, `SSH_USER`, `SSH_KEY` |

---

## Environments (opcional, para deploy a producción)

GitHub permite crear **environments** para requerir aprobación manual antes de desplegar.

### Configurar environment `production`

1. **Settings** → **Environments** → **New environment**.
2. Nombre: `production`.
3. Marcar **Required reviewers** → seleccionar tu usuario.
4. Guardar.

En el workflow de deploy, usar:

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    environment:
      name: production
      url: https://tu-dominio.com
```

Con esto, cada vez que se dispare el workflow, GitHub pedirá aprobación manual antes de ejecutar los pasos.

---

## Checklist de configuración inicial

Al crear un proyecto nuevo, configura estos secrets:

- [ ] `CODECOV_TOKEN` (obligatorio para cobertura)
- [ ] `SSH_HOST`, `SSH_USER`, `SSH_KEY` (si usas deploy a VPS)
- [ ] Verificar que `GITHUB_TOKEN` esté disponible (es automático)
- [ ] Crear environment `production` (si usas deploy con aprobación)

---

## Verificación

Para verificar que un secret está configurado correctamente:

1. Ir a **Settings** → **Secrets and variables** → **Actions**.
2. Verificar que el secret aparece en la lista.
3. Hacer un push a `main` y verificar que el workflow que lo usa se ejecuta sin errores de autenticación.

---

## Rotación de secrets

| Secret | Frecuencia recomendada |
|--------|------------------------|
| `CODECOV_TOKEN` | Cada 6 meses |
| `SSH_KEY` | Cada 6 meses |
| `VERCEL_TOKEN` | Cada 6 meses |
| `DOCKER_TOKEN` | Cada 6 meses |
| `CLOUDFLARE_TOKEN` | Cada 6 meses |

**Procedimiento de rotación:**

1. Generar nuevo valor en el servicio correspondiente.
2. Actualizar el secret en GitHub (Settings → Secrets → Edit).
3. Verificar que los workflows siguen funcionando.
4. Revocar el valor anterior en el servicio.

---

## Si un secret se filtra

1. **Revocar inmediatamente** el secret en el servicio de origen.
2. **Rotarlo** (crear uno nuevo y reemplazar en GitHub).
3. **Revisar logs** para detectar usos no autorizados.
4. **Documentar** el incidente en `docs/Plan_Pruebas.md` → sección 9 (excepciones).
5. **Si el secret estaba en Git**, eliminar del historial con `git filter-repo` o BFG.

---

## Referencias

- [`../docs/WORKFLOWS.md`](WORKFLOWS.md) — Documentación de workflows
- [`../docs/SEGURIDAD.md`](SEGURIDAD.md) — Alineación NIST SSDF
- [`../docs/deploy.yml.example`](deploy.yml.example) — Plantillas de deploy
- [GitHub Docs — Encrypted secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
