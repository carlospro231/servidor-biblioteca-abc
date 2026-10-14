#!/bin/bash
# ==============================================================================
# MÓDULO 4 — RESPONSABLE: CARLOS ENRIQUE CHOQUE RAMOS
# Tema que vas a sustentar el lunes:
#   - Viabilidad técnica (Ubuntu Server Headless < 500 MB RAM) y arquitectura en VMware
#   - Solución al INCIDENTE 5 (Corte eléctrico apagó el servidor y al volver la luz
#     no arrancó Samba -> Persistencia con systemd y RequiresMountsFor=/srv)
#   - Seguridad perimetral con Firewall UFW e Integración Total de los 4 módulos
# ==============================================================================

DIR_ACTUAL="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=================================================================="
echo " [MÓDULO 4 - CARLOS CHOQUE] SEGURIDAD, SYSTEMD E INTEGRACIÓN VMWARE"
echo "=================================================================="

# 1. Configuración de dependencia en Systemd para que Samba espere a /srv (Incidente 5)
mkdir -p /etc/systemd/system/smbd.service.d
cat > /etc/systemd/system/smbd.service.d/override.conf << 'EOF'
[Unit]
RequiresMountsFor=/srv
EOF

if command -v systemctl >/dev/null 2>&1 && systemctl is-system-running >/dev/null 2>&1; then
    systemctl daemon-reload
    systemctl enable smbd nmbd
    systemctl restart smbd nmbd
    echo " [OK] Incidente 5 resuelto: smbd y nmbd habilitados en arranque automático con systemd."
else
    echo " [OK] Archivo /etc/systemd/system/smbd.service.d/override.conf creado (Se activará en VMware)."
fi

# 2. Configuración del Firewall UFW (Sección 4.6 del Informe)
export DEBIAN_FRONTEND=noninteractive
apt-get install -y ufw quota >/dev/null 2>&1 || true
if command -v ufw >/dev/null 2>&1; then
    ufw allow Samba >/dev/null 2>&1 || true
    echo " [OK] Regla de Firewall 'ufw allow Samba' registrada."
fi

echo ""
echo "=================================================================="
echo " EJECUTANDO INTEGRACIÓN DE LOS MÓDULOS DE JOSEPH, MATHIAS Y FRANCO"
echo "=================================================================="
bash "$DIR_ACTUAL/01_joseph_estructura_permisos.sh"
bash "$DIR_ACTUAL/02_mathias_samba_acceso.sh"
bash "$DIR_ACTUAL/03_franco_respaldo_auditoria.sh"

echo ""
echo "=================================================================="
echo " EVIDENCIA DE CARLOS (TOMAR CAPTURA EN VMWARE WORKSTATION):"
echo "=================================================================="
free -h
df -hT
cat /etc/systemd/system/smbd.service.d/override.conf
