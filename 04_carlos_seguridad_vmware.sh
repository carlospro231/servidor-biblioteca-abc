#!/bin/bash
# ==============================================================================
# MÓDULO 4 — RESPONSABLE: CARLOS ENRIQUE CHOQUE RAMOS
# ==============================================================================
DIR_ACTUAL="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=================================================================="
echo " [MÓDULO 4 - CARLOS CHOQUE] INTEGRACIÓN Y DESPLIEGUE FINAL"
echo "=================================================================="

# 1. Ejecutar los módulos de los compañeros (si ya tienen código)
bash "$DIR_ACTUAL/01_joseph_estructura_permisos.sh" 2>/dev/null || echo "[AVISO] Error en Módulo 1"
bash "$DIR_ACTUAL/02_mathias_samba_acceso.sh" 2>/dev/null || echo "[AVISO] Error en Módulo 2"
bash "$DIR_ACTUAL/03_franco_respaldo_auditoria.sh" 2>/dev/null || echo "[AVISO] Error en Módulo 3"

# 2. Resolver Incidente 5: Dependencia de montaje en Systemd y arranque automático
mkdir -p /etc/systemd/system/smbd.service.d
cat > /etc/systemd/system/smbd.service.d/override.conf << 'CONF'
[Unit]
RequiresMountsFor=/srv
CONF

if [ -d /run/systemd/system ]; then
    systemctl daemon-reload
    systemctl enable smbd nmbd
    systemctl restart smbd nmbd
else
    service smbd restart >/dev/null 2>&1 || true
fi

# 3. Seguridad Perimetral: Instalar y abrir Samba en el Firewall UFW y Cuotas
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y ufw quota
ufw allow Samba
ufw --force enable 2>/dev/null || true

# 4. Diagnóstico de consumo de RAM (< 500 MB) y particiones
free -h
df -hT

echo ""
echo "=================================================================="
echo " RESUMEN DE AVANCE DEL GRUPO (VERIFICADOR AUTOMÁTICO):"
echo "=================================================================="

# Verificación Módulo 1 (Joseph)
if [ "$(stat -c '%a' /srv/biblioteca/tesis 2>/dev/null)" = "3775" ] && [ "$(stat -c '%a' /srv/biblioteca/metadatos 2>/dev/null)" = "2775" ]; then
    echo " 1. Módulo Joseph (Carpetas, Usuarios y Permisos 3775/2775): [COMPLETO]"
else
    echo " 1. Módulo Joseph (Carpetas, Usuarios y Permisos 3775/2775): [PENDIENTE]"
fi

# Verificación Módulo 2 (Mathias)
if grep -q "SMB2_02" /etc/samba/smb.conf 2>/dev/null && grep -q "recycle" /etc/samba/smb.conf 2>/dev/null; then
    echo " 2. Módulo Mathias (Samba smb.conf, Papelera y Usuarios):    [COMPLETO]"
else
    echo " 2. Módulo Mathias (Samba smb.conf, Papelera y Usuarios):    [PENDIENTE]"
fi

# Verificación Módulo 3 (Franco)
if [ -x /usr/local/sbin/respaldo_biblioteca.sh ] && crontab -l 2>/dev/null | grep -q "respaldo_biblioteca.sh"; then
    echo " 3. Módulo Franco (Script Backup rsync y Crontab 02:00 AM):  [COMPLETO]"
else
    echo " 3. Módulo Franco (Script Backup rsync y Crontab 02:00 AM):  [PENDIENTE]"
fi

# Verificación Módulo 4 (Carlos)
if [ -f /etc/systemd/system/smbd.service.d/override.conf ]; then
    echo " 4. Módulo Carlos (Systemd, Firewall e Integración VMware):  [COMPLETO]"
else
    echo " 4. Módulo Carlos (Systemd, Firewall e Integración VMware):  [PENDIENTE]"
fi

echo "=================================================================="