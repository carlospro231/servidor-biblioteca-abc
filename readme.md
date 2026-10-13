# Servidor Linux de la Biblioteca Universitaria ABC (Fase OPERAR)

**Curso:** Sistemas Operativos Linux (Sección G2) — FIEE UNMSM  
**Docente:** Ing. Luis Ricardo Solano Hurtado  

**Integrantes del Equipo:**
1. **Choque Ramos, Carlos Enrique** (`04_carlos_seguridad_vmware.sh`)
2. **Gomero Mendoza, Joseph Patrick** (`01_joseph_estructura_permisos.sh`)
3. **Marcelo Mego, Mathias Fabricio** (`02_mathias_samba_acceso.sh`)
4. **Gamarra Paico, Franco Antonio** (`03_franco_respaldo_auditoria.sh`)

## Cómo entrar a trabajar desde tu navegador (Sin instalar nada)

1. En la página principal de este repositorio en GitHub, haz clic en el botón verde **`<> Code`** (arriba a la derecha).
2. Selecciona la pestaña **`Codespaces`**.
3. Haz clic en **`Create codespace on main`** (o abre el Codespace ya creado).
4. Espera 20 segundos a que cargue la pantalla tipo Visual Studio Code en tu navegador: en la parte de abajo verás la **Terminal de Ubuntu** lista para usar.

## Qué comando debe ejecutar cada integrante y qué captura debe tomar

Cada integrante debe ejecutar su script en la terminal de Codespaces (Si entras a un Codespace nuevo, ejecuta primero los scripts anteriores al tuyo para que existan las carpetas y usuarios):

| Integrante | Comando a escribir en la Terminal | Qué hace automáticamente | Captura de pantalla que debes tomar y subir a las diapositivas |
| :--- | :--- | :--- | :--- |
| **1. Joseph Gomero** | `sudo bash 01_joseph_estructura_permisos.sh` | Crea `/srv/biblioteca/{publico,departamental,privado,tesis,metadatos}`, los 5 grupos RBAC, los usuarios y aplica **Sticky Bit (`3775`)** en `tesis` y **SGID (`2775`)** en `metadatos` (**Incidentes 1 y 2**). | Captura del resultado final en consola mostrando `ls -ld /srv/biblioteca/*` (donde se ve `drwxrwsr-t` en `tesis` y `drwxrwsr-x` en `metadatos`) y la lista de grupos creados (**Diapositivas 5, 7 y 11**). |
| **2. Mathias Marcelo** | `sudo bash 01_joseph_estructura_permisos.sh && sudo bash 02_mathias_samba_acceso.sh` | Instala Samba, configura `/etc/samba/smb.conf` (`map to guest = Never`, `SMB2_02`, papelera `recycle`, bloqueo `veto files = /*.iso/*.mp4/*.mkv/*.avi/`), registra claves con `smbpasswd -a` y prueba la conexión (**Incidentes 3 y 4**). | Captura del resultado de `testparm -s`, lista de usuarios en `pdbedit -L` y la prueba real donde `alumno01` intenta borrar una tesis y recibe `NT_STATUS_ACCESS_DENIED` (**Diapositivas 8 y 12**). |
| **3. Franco Gamarra** | `sudo bash 01_joseph_estructura_permisos.sh && sudo bash 02_mathias_samba_acceso.sh && sudo bash 03_franco_respaldo_auditoria.sh` | Crea `/mnt/respaldo/biblioteca`, instala el script `/usr/local/sbin/respaldo_biblioteca.sh` con `rsync -aHAX --link-dest`, programa `crontab` a las 02:00 a.m. y ejecuta un respaldo en vivo (**Incidente 6**). | Captura del respaldo incremental creado en `/mnt/respaldo/biblioteca/ultimo`, salida de `sudo crontab -l` y auditoría con `sudo smbstatus` (**Diapositivas 13 y 14**). |
| **4. Carlos Choque** | `sudo bash 04_carlos_seguridad_vmware.sh` | Ejecuta la integración completa en **VMware Workstation**, activa el firewall `ufw allow Samba`, configura la persistencia en `systemd` (`RequiresMountsFor=/srv`) y mide la RAM (**Incidente 5**). | Captura en VMware Workstation mostrando `free -h` (< 500 MB RAM), `sudo ufw status`, `systemctl status smbd` y `df -h` (**Diapositivas 4, 6, 9 y 10**). |

## Cómo pasar todo a VMware Workstation el domingo en 1 minuto

Dentro de la máquina virtual Ubuntu Server en **VMware Workstation**, ejecuta:

```bash
git clone https://github.com/TU_USUARIO/TU_REPOSITORIO.git
cd TU_REPOSITORIO
sudo bash 04_carlos_seguridad_vmware.sh
```
