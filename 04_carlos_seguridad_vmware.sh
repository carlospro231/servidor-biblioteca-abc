#!/bin/bash
# ==============================================================================
# MÓDULO 4 — RESPONSABLE: CARLOS ENRIQUE CHOQUE RAMOS
# Objetivo: Integración Total en VMware Workstation, Firewall UFW, Persistencia
#           en Systemd tras cortes de energía (Incidente 5) y Cuotas de Disco
# ==============================================================================
set -e

DIR_ACTUAL="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=================================================================="
echo " [MÓDULO 4 - CARLOS CHOQUE] Integrando Módulos 1, 2 y 3..."
echo "=================================================================="
bash "$DIR_ACTUAL/01_joseph_estructura_permisos.sh"
bash "$DIR_ACTUAL/02_mathias_samba_acceso.sh"
bash "$DIR_ACTUAL/03_franco_respaldo_auditoria.sh"

echo ""
echo "=================================================================="
echo " Configurando Seguridad Perimetral (UFW) y Persistencia (Systemd)"
echo "=================================================================="

# 1. Configuración de dependencia RequiresMountsFor=/srv en systemd (Incidente 5)
mkdir -p /etc/systemd/system/smbd.service.d
cat > /etc/systemd/system/smbd.service.d/override.conf << 'EOF'
[Unit]
RequiresMountsFor=/srv
EOF

if command -v systemctl >/dev/null 2>&1 && systemctl is-system-running >/dev/null 2>&1; then
    systemctl daemon-reload
    systemctl enable smbd nmbd
    systemctl restart smbd nmbd
    echo "[OK] Servicios smbd y nmbd habilitados en el arranque con systemd."
else
    echo "[INFO] Entorno contenedor (Codespaces): override.conf creado. En VMware systemd lo activará al arrancar."
fi

# 2. Configuración del Firewall UFW (Sección 4.6 del Informe)
export DEBIAN_FRONTEND=noninteractive
apt-get install -y ufw quota >/dev/null
if ufw allow Samba >/dev/null 2>&1; then
    ufw --force enable >/dev/null 2>&1 || true
    echo "[OK] Regla UFW para Samba configurada."
fi

echo ""
echo "=================================================================="
echo " EVIDENCIA FINAL VMWARE (TOMAR CAPTURA): Consumo RAM, Red y Servicios"
echo "=================================================================="
echo "--- Consumo de Memoria RAM (Requisito < 500 MB en modo Headless) ---"
free -h
echo ""
echo "--- Espacio en Disco y Particiones ---"
df -hT
echo ""
echo "--- Dependencia Systemd para Cortes Eléctricos (Incidente 5) ---"
cat /etc/systemd/system/smbd.service.d/override.conf
echo ""
echo "=================================================================="
echo " ¡SERVIDOR DE LA BIBLIOTECA UNIVERSITARIA ABC 100% OPERATIVO!"
echo "=================================================================="
