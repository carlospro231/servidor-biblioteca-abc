#!/bin/bash
# ==============================================================================
# MÓDULO 2 — RESPONSABLE: MATHIAS FABRICIO MARCELO MEGO
# Objetivo: Instalación y Configuración de Samba (smb.conf), Registro tdbsam,
#           Papelera (vfs_recycle), Bloqueo de videos/ISOs y Pruebas SMB
#           (Resuelve Incidentes 1, 2, 3 y 4 — RF-01 y RF-04)
# ==============================================================================
set -e

echo "=================================================================="
echo " [MÓDULO 2 - MATHIAS MARCELO] Instalando y configurando Samba"
echo "=================================================================="

export DEBIAN_FRONTEND=noninteractive
apt-get update -y >/dev/null
apt-get install -y samba smbclient >/dev/null

# 1. Respaldo del archivo original smb.conf
if [ ! -f /etc/samba/smb.conf.bak ]; then
    cp /etc/samba/smb.conf /etc/samba/smb.conf.bak
fi

# 2. Configuración maestra de /etc/samba/smb.conf
cat > /etc/samba/smb.conf << 'EOF'
[global]
   workgroup = WORKGROUP
   server string = Servidor de Archivos Biblioteca ABC
   security = user
   passdb backend = tdbsam
   map to guest = Never
   server min protocol = SMB2_02
   log file = /var/log/samba/log.%m
   max log size = 1000
   logging = file

[Publico]
   comment = Repositorio Publico de la Biblioteca
   path = /srv/biblioteca/publico
   browseable = yes
   read only = no
   guest ok = no
   valid users = @usuarios_consulta @bibliotecarios @admin_ti
   veto files = /*.iso/*.mp4/*.mkv/*.avi/
   delete veto files = yes

[Departamental]
   comment = Archivos de la Administracion y Bibliotecarios
   path = /srv/biblioteca/departamental
   browseable = yes
   read only = no
   guest ok = no
   valid users = @bibliotecarios @admin_ti

[tesis]
   comment = Repositorio de Tesis Digitalizadas
   path = /srv/biblioteca/tesis
   browseable = yes
   valid users = @catalogacion @consulta
   read only = yes
   write list = @catalogacion
   vfs objects = recycle
   recycle:repository = .papelera/%U
   recycle:keeptree = yes
   recycle:versions = yes
   veto files = /*.iso/*.mp4/*.mkv/*.avi/
   delete veto files = yes

[metadatos]
   comment = Base de Datos y Catalogacion Colaborativa
   path = /srv/biblioteca/metadatos
   browseable = yes
   valid users = @catalogacion
   read only = no
   force group = catalogacion
   create mask = 0664
   directory mask = 0775
   force directory mode = 2775
   locking = yes
EOF

# 3. Registro de usuarios en la base de datos tdbsam de Samba (Incidente 3)
CLAVE_DEMO="Biblio2026*"
for usr in carlos alumno01 cat01 cat02 adq01 tesista01; do
    if id -u "$usr" >/dev/null 2>&1; then
        (echo "$CLAVE_DEMO"; echo "$CLAVE_DEMO") | smbpasswd -s -a "$usr" >/dev/null
        smbpasswd -e "$usr" >/dev/null
    fi
done

# 4. Reinicio del servicio Samba (compatible con Codespaces y con VMware)
if command -v systemctl >/dev/null 2>&1 && systemctl is-system-running >/dev/null 2>&1; then
    systemctl restart smbd nmbd || service smbd restart
else
    service smbd restart || /usr/sbin/smbd -D
fi

echo ""
echo "=================================================================="
echo " EVIDENCIA 1 (TOMAR CAPTURA): Validación de smb.conf (testparm)"
echo "=================================================================="
testparm -s

echo ""
echo "=================================================================="
echo " EVIDENCIA 2 (TOMAR CAPTURA): Usuarios registrados en tdbsam"
echo "=================================================================="
pdbedit -L

echo ""
echo "=================================================================="
echo " EVIDENCIA 3 (TOMAR CAPTURA): Prueba de Incidente 1 (Alumno intenta"
echo " borrar tesis y recibe NT_STATUS_ACCESS_DENIED)"
echo "=================================================================="
smbclient //localhost/tesis -U alumno01%"$CLAVE_DEMO" -c "ls; rm tesis_fiee_2026.pdf" || true
