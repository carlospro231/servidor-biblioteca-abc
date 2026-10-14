# Servidor Linux de la Biblioteca Universitaria ABC — Guía de Implementación Grupal

**Curso:** Sistemas Operativos Linux (Sección G2) — FIEE UNMSM  
**Docente:** Ing. Luis Ricardo Solano Hurtado  

**Integrantes y Módulos Asignados:**
1. **Gomero Mendoza, Joseph Patrick** → `01_joseph_estructura_permisos.sh` *(Carpetas FHS, Grupos/Usuarios RBAC y Permisos 3775/2775 — Incidentes 1 y 2)*
2. **Marcelo Mego, Mathias Fabricio** → `02_mathias_samba_acceso.sh` *(Configuración de Samba, Papelera, Bloqueo de ISOs/Videos y Claves — Incidentes 3 y 4)*
3. **Gamarra Paico, Franco Antonio** → `03_franco_respaldo_auditoria.sh` *(Backups automáticos con rsync + cron a las 02:00 a.m. y Auditoría — Incidente 6)*
4. **Choque Ramos, Carlos Enrique** → `04_carlos_seguridad_vmware.sh` *(Firewall UFW, Persistencia ante apagones con Systemd e Integración en VMware — Incidente 5)*

## ¿De qué trata nuestro servidor y cómo vamos a armarlo juntos?

En lugar de que una sola persona haga todo, cada integrante va a programar y probar su parte del servidor Linux desde su navegador usando **GitHub Codespaces** (una máquina virtual Ubuntu gratuita en la nube). Cuando los 4 archivos estén completos y verificados aquí en GitHub, Carlos los descargará con un comando en el **VMware Workstation** de su laptop para mostrárselo funcionando en vivo al profesor el lunes.

## Paso a Paso: Cómo entrar, completar tu parte y guardarla (15 minutos)

### Paso 1: Abrir la máquina virtual Ubuntu en tu navegador
1. Arriba a la derecha en esta página de GitHub, haz clic en el botón verde **`<> Code`**.
2. Cambia a la pestaña **`Codespaces`** y haz clic en **`Create codespace on main`**.
3. Espera unos 20 segundos: se abrirá un editor (como Visual Studio Code) con los archivos a la izquierda y una **Terminal de Ubuntu** en la parte de abajo.

### Paso 2: Completar los comandos guiados de tu archivo `.sh`
1. En la columna izquierda, haz clic sobre el archivo `.sh` que tiene tu nombre.
2. Lee las explicaciones de cada paso (allí dice qué problema de la biblioteca estás resolviendo para que sepas explicarlo en la exposición del lunes).
3. En cada sección verás un bloque que dice **`# >>> COMPLETA AQUÍ <<<`** con un ejemplo justo arriba. Escribe los comandos que faltan siguiendo el ejemplo.

### Paso 3: Probar tu avance con el Autoverificador Automático
En la terminal de abajo, ejecuta tu archivo para que el **Autoverificador** te diga con `[OK]` o `[FALTA]` si ya cumpliste todos los objetivos de tu parte:

* **Joseph:** `sudo bash 01_joseph_estructura_permisos.sh`
* **Mathias:** `sudo bash 02_mathias_samba_acceso.sh`
* **Franco:** `sudo bash 03_franco_respaldo_auditoria.sh`
* **Carlos:** `sudo bash 04_carlos_seguridad_vmware.sh`

Cuando todos los puntos de tu autoverificador digan **`[OK]`**, toma captura de pantalla de ese resultado para ponerla en tus diapositivas del lunes.

### Paso 4: Guardar tu avance en el repositorio del grupo (Importante)
Para que lo que escribiste quede guardado en el repositorio de GitHub y pase al VMware de la laptop:
1. En la barra de iconos del extremo izquierdo de Codespaces, haz clic en el tercer icono (**Control de código fuente / Source Control**, que parece una ramita con un número azul).
2. En la cajita de texto de arriba escribe: `Avance listo de [Tu Nombre]`.
3. Haz clic en el botón azul **`Commit`** y luego en **`Sync Changes` (o `Push`)**.
