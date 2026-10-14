# Servidor Linux de la Biblioteca Universitaria ABC — Fase OPERAR

**Curso:** Sistemas Operativos Linux (Sección G2) — FIEE UNMSM  
**Docente:** Ing. Luis Ricardo Solano Hurtado  

**Integrantes y Módulos Asignados:**
1. **Gomero Mendoza, Joseph Patrick** → `01_joseph_estructura_permisos.sh`
2. **Marcelo Mego, Mathias Fabricio** → `02_mathias_samba_acceso.sh`
3. **Gamarra Paico, Franco Antonio** → `03_franco_respaldo_auditoria.sh`
4. **Choque Ramos, Carlos Enrique** → `04_carlos_seguridad_vmware.sh`

## Objetivo

Implementar entre los 4 integrantes el **Servidor Linux de la Biblioteca Universitaria ABC** cumpliendo los requerimientos funcionales (`RF-01` a `RF-06`) y la resolución de los **6 incidentes operativos** del proyecto, para ejecutarlo y **demostrarlo funcionando en vivo al profesor** en la máquina virtual (**VMware Workstation**) el lunes.

## Cómo trabajar tu parte desde el navegador

1. Haz clic en el botón verde **`<> Code`** → pestaña **`Codespaces`** → **`Create codespace on main`**.
2. Usa la **Terminal de Ubuntu** de abajo para probar libremente los comandos de Linux que resuelven los objetivos de tu módulo.
3. Cuando tus comandos funcionen, escríbelos en orden dentro de tu archivo `.sh` (en el panel izquierdo) y verifica que corra completo con `sudo bash tu_archivo.sh`.
4. Guarda tus cambios en el repositorio yendo al icono izquierdo de **Source Control** → escribe un mensaje → **`Commit`** → **`Sync Changes`**.

## Objetivos Técnicos por Integrante

| Integrante y Archivo | Objetivos Técnicos que debes implementar en Linux | Qué debes saber demostrar en vivo al profesor el lunes |
| :--- | :--- | :--- |
| **1. Joseph Gomero**<br>`01_joseph_estructura_permisos.sh` | 1. Crear la estructura `/srv/biblioteca/` (`publico`, `departamental`, `privado`, `tesis`, `metadatos`).<br>2. Crear los grupos RBAC (`admin_ti`, `bibliotecarios`, `usuarios_consulta`, `catalogacion`, `consulta`) y usuarios (`carlos`, `alumno01`, `cat01`, `cat02`, `adq01`, `tesista01`).<br>3. Aplicar permisos `770` (`departamental`), `775` (`publico`), **Sticky Bit + SGID (`3775`)** en `tesis` (**Incidente 1**) y **SGID (`2775`)** en `metadatos` (**Incidente 2**). | Crear y verificar usuarios, grupos y permisos especiales con `mkdir`, `groupadd`, `useradd`, `chown`, `chmod 3775`, `chmod 2775` y `ls -ld /srv/biblioteca/*`. |
| **2. Mathias Marcelo**<br>`02_mathias_samba_acceso.sh` | 1. Instalar `samba` y `smbclient` y configurar `/etc/samba/smb.conf` para `[Publico]`, `[Departamental]`, `[tesis]` y `[metadatos]`.<br>2. Configurar `map to guest = Never`, `server min protocol = SMB2_02` y dar de alta usuarios con `smbpasswd -a` (**Incidente 3**).<br>3. Activar papelera (`vfs objects = recycle`) en `[tesis]` y bloqueo de archivos pesados (`veto files = /*.iso/*.mp4/*.mkv/*.avi/`) (**Incidente 4**). | Explicar `/etc/samba/smb.conf`, registrar usuarios con `smbpasswd -a`, listar con `pdbedit -L`, validar con `testparm -s` y probar el acceso/bloqueo con `smbclient`. |
| **3. Franco Gamarra**<br>`03_franco_respaldo_auditoria.sh` | 1. Crear `/mnt/respaldo/biblioteca` y el script `/usr/local/sbin/respaldo_biblioteca.sh` con respaldo incremental (`rsync -aHAX --delete --link-dest`) y retención de 30 días (`find -mtime +30`) (**Incidente 6**).<br>2. Dar permiso `750` al script y programarlo en `crontab` a las 02:00 a.m. (`0 2 * * *`).<br>3. Auditar accesos y sesiones activas (`RF-06`). | Ejecutar el script de backup, mostrar `crontab -l`, recuperar un archivo borrado desde `/mnt/respaldo/biblioteca/ultimo/` y auditar conexiones con `sudo smbstatus`. |
| **4. Carlos Choque**<br>`04_carlos_seguridad_vmware.sh` | 1. Habilitar `smbd` y `nmbd` en el arranque con `systemd` y configurar la dependencia `RequiresMountsFor=/srv` (**Incidente 5**).<br>2. Activar el firewall `ufw` para `Samba` y cuotas de disco (`quota`).<br>3. Integrar los 4 módulos en **VMware Workstation** en la laptop y conectar desde Windows. | Mostrar consumo de recursos (`free -h`, `df -hT`), estado de `systemctl status smbd`, `ufw status` y acceso a las carpetas compartidas desde Windows. |
