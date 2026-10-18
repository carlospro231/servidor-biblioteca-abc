#!/bin/bash
# MÓDULO 2 — SAMBA (smb.conf), TDBSAM, PAPELERA RECYCLE Y BLOQUEO VETO FILES
export DEBIAN_FRONTEND=noninteractive
apt-get update -y >/dev/null
apt-get install -y samba smbclient >/dev/null

cp -n /etc/samba/smb.conf /etc/samba/smb.conf.bak 2>/dev/null || true

cat > /etc/samba/smb.conf << 'SMB'
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
SMB

CLAVE_SMB="Biblio2026*"
for usr in carlos alumno01 cat01 cat02 adq01 tesista01; do
    if id -u "$usr" >/dev/null 2>&1; then
        (echo "$CLAVE_SMB"; echo "$CLAVE_SMB") | smbpasswd -s -a "$usr" >/dev/null
        smbpasswd -e "$usr" >/dev/null
    fi
done

if [ -d /run/systemd/system ]; then
    systemctl restart smbd nmbd
else
    service smbd restart >/dev/null 2>&1 || /usr/sbin/smbd -D 2>/dev/null || true
fi
