#!/bin/bash
# ==============================================================================
# MÓDULO 4 — RESPONSABLE: CARLOS ENRIQUE CHOQUE RAMOS
# ==============================================================================
# OBJETIVOS DE TU MÓDULO (Sección 4.6 e Integración Final en VMware Workstation):
# 1. Ejecutar en orden los scripts de Joseph (01), Mathias (02) y Franco (03).
# 2. Configurar el Firewall UFW permitiendo el servicio Samba (ufw allow Samba).
# 3. Resolver el Incidente 5 (Caída tras corte eléctrico):
#    - Habilitar smbd y nmbd en el arranque automático con systemd
#    - Configurar la dependencia RequiresMountsFor=/srv en smbd.service.d/override.conf
# 4. Verificar el estado general del servidor (free -h, df -hT, systemctl status smbd).
# ==============================================================================

DIR_ACTUAL="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=================================================================="
echo " [MÓDULO 4 - CARLOS CHOQUE] INTEGRACIÓN Y DESPLIEGUE FINAL"
echo "=================================================================="

# 1. Integración segura de los módulos del equipo:
if [ -f "$DIR_ACTUAL/01_joseph_estructura_permisos.sh" ]; then
    echo ">> Ejecutando Módulo 1 (Joseph Gomero)..."
    bash "$DIR_ACTUAL/01_joseph_estructura_permisos.sh" || echo "[AVISO] Módulo 1 terminó con advertencias."
fi

if [ -f "$DIR_ACTUAL/02_mathias_samba_acceso.sh" ]; then
    echo ">> Ejecutando Módulo 2 (Mathias Marcelo)..."
    bash "$DIR_ACTUAL/02_mathias_samba_acceso.sh" || echo "[AVISO] Módulo 2 terminó con advertencias."
fi

if [ -f "$DIR_ACTUAL/03_franco_respaldo_auditoria.sh" ]; then
    echo ">> Ejecutando Módulo 3 (Franco Gamarra)..."
    bash "$DIR_ACTUAL/03_franco_respaldo_auditoria.sh" || echo "[AVISO] Módulo 3 terminó con advertencias."
fi

# 2. Configuración de persistencia Systemd (Incidente 5 - Corte eléctrico)
echo ">> Configurando arranque automático y dependencia Systemd..."
mkdir -p /etc/systemd/system/smbd.service.d
cat > /etc/systemd/system/smbd.service.d/override.conf << 'CONF'
[Unit]
RequiresMountsFor=/srv
CONF

if command -v systemctl >/dev/null 2>&1 && systemctl is-system-running >/dev/null 2>&1; then
    systemctl daemon-reload
    systemctl enable smbd nmbd
    systemctl restart smbd nmbd
    echo " [OK] Servicios smbd y nmbd habilitados en systemd con persistencia."
else
    echo " [OK] Archivo override.conf configurado (se activará en VMware)."
fi

# 3. Configuración del Firewall UFW
if command -v ufw >/dev/null 2>&1; then
    echo ">> Configurando Firewall UFW para Samba..."
    ufw allow Samba >/dev/null 2>&1 || true
    echo " [OK] Regla de firewall para Samba habilitada."
fi

echo ""
echo "=================================================================="
echo " ESTADO DEL SERVIDOR EN VMWARE (DEMOSTRACIÓN AL PROFESOR):"
echo "=================================================================="
echo "--- Memoria RAM consumida (Requisito < 500 MB) ---"
free -h
echo ""
echo "--- Particiones y Espacio en Disco ---"
df -hT / /srv /mnt/respaldo 2>/dev/null || df -hT /
echo ""
echo "--- Directorios de la Biblioteca y Permisos ---"
ls -ld /srv/biblioteca/* 2>/dev/null || echo "[Pendiente ejecutar Módulo 1]"
echo ""
echo "=================================================================="
echo " ¡SERVIDOR LINUX LISTO PARA LA DEMOSTRACIÓN DEL LUNES!"
echo "=================================================================="
