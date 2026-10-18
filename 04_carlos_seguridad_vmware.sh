#!/bin/bash
# MÓDULO 4 — SEGURIDAD UFW, PERSISTENCIA SYSTEMD E INTEGRACIÓN TOTAL
DIR_ACTUAL="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

bash "$DIR_ACTUAL/01_joseph_estructura_permisos.sh"
bash "$DIR_ACTUAL/02_mathias_samba_acceso.sh"
bash "$DIR_ACTUAL/03_franco_respaldo_auditoria.sh"

mkdir -p /etc/systemd/system/smbd.service.d
cat > /etc/systemd/system/smbd.service.d/override.conf << 'CONF'
[Unit]
RequiresMountsFor=/srv
CONF

export DEBIAN_FRONTEND=noninteractive
apt-get install -y ufw quota >/dev/null 2>&1 || true
if command -v ufw >/dev/null 2>&1; then
    ufw allow Samba >/dev/null 2>&1 || true
    ufw --force enable >/dev/null 2>&1 || true
fi

if [ -d /run/systemd/system ]; then
    systemctl daemon-reload
    systemctl enable smbd nmbd
    systemctl restart smbd nmbd
else
    service smbd restart >/dev/null 2>&1 || true
fi

echo ""
echo "=================================================================="
echo " RESUMEN DE AVANCE DEL GRUPO (VERIFICADOR AUTOMÁTICO):"
echo "=================================================================="

if [ "$(stat -c '%a' /srv/biblioteca/tesis 2>/dev/null)" = "3775" ] && [ "$(stat -c '%a' /srv/biblioteca/metadatos 2>/dev/null)" = "2775" ]; then
    echo " 1. Módulo Joseph (Carpetas, Usuarios y Permisos 3775/2775): [COMPLETO]"
else
    echo " 1. Módulo Joseph (Carpetas, Usuarios y Permisos 3775/2775): [PENDIENTE]"
fi

if grep -q "SMB2_02" /etc/samba/smb.conf 2>/dev/null && grep -q "recycle" /etc/samba/smb.conf 2>/dev/null; then
    echo " 2. Módulo Mathias (Samba smb.conf, Papelera y Usuarios):    [COMPLETO]"
else
    echo " 2. Módulo Mathias (Samba smb.conf, Papelera y Usuarios):    [PENDIENTE]"
fi

if [ -x /usr/local/sbin/respaldo_biblioteca.sh ] && crontab -l 2>/dev/null | grep -q "respaldo_biblioteca.sh"; then
    echo " 3. Módulo Franco (Script Backup rsync y Crontab 02:00 AM):  [COMPLETO]"
else
    echo " 3. Módulo Franco (Script Backup rsync y Crontab 02:00 AM):  [PENDIENTE]"
fi

if grep -q "RequiresMountsFor=/srv" /etc/systemd/system/smbd.service.d/override.conf 2>/dev/null && command -v ufw >/dev/null 2>&1; then
    echo " 4. Módulo Carlos (Systemd, Firewall e Integración VMware):  [COMPLETO]"
else
    echo " 4. Módulo Carlos (Systemd, Firewall e Integración VMware):  [PENDIENTE]"
fi

echo "=================================================================="
echo ""
echo "--- Directorios y Permisos Creados en /srv/biblioteca/ ---"
ls -ld /srv/biblioteca/*
echo ""
echo "--- Usuarios Registrados en Samba (tdbsam) ---"
pdbedit -L
echo ""
echo "--- Respaldo Incremental Creado en /mnt/respaldo/biblioteca/ultimo ---"
ls -la /mnt/respaldo/biblioteca/ultimo/
echo "=================================================================="
