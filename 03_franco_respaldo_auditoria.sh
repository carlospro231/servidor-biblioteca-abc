#!/bin/bash
# ==============================================================================
# MÓDULO 3 — RESPONSABLE: FRANCO ANTONIO GAMARRA PAICO
# Objetivo: Automatización de Respaldos Incrementales (rsync + cron a las 02:00)
#           y Auditoría de Accesos en Tiempo Real (Incidente 6 y RF-06)
# ==============================================================================
set -e

echo "=================================================================="
echo " [MÓDULO 3 - FRANCO GAMARRA] Configurando Backups (rsync + cron)"
echo "=================================================================="

export DEBIAN_FRONTEND=noninteractive
apt-get install -y rsync cron >/dev/null

# 1. Crear directorio de destino de respaldos (/mnt/respaldo/biblioteca)
mkdir -p /mnt/respaldo/biblioteca

# 2. Crear el script oficial /usr/local/sbin/respaldo_biblioteca.sh (Sección 5.2 del Informe)
cat > /usr/local/sbin/respaldo_biblioteca.sh << 'EOF'
#!/bin/bash
# Sistema de Respaldo Incremental Automatizado - Biblioteca Universitaria ABC
DEST="/mnt/respaldo/biblioteca"
HOY=$(date +%F)
mkdir -p "$DEST"

if [ -d "$DEST/ultimo" ]; then
    rsync -aHAX --delete --link-dest="$DEST/ultimo" /srv/biblioteca/ "$DEST/$HOY/" >> /var/log/respaldo.log 2>&1       && ln -sfn "$DEST/$HOY" "$DEST/ultimo"
else
    rsync -aHAX --delete /srv/biblioteca/ "$DEST/$HOY/" >> /var/log/respaldo.log 2>&1       && ln -sfn "$DEST/$HOY" "$DEST/ultimo"
fi

# Política de retención: purga de respaldos con antigüedad mayor a 30 días
find "$DEST" -mindepth 1 -maxdepth 1 -type d -mtime +30 -exec rm -rf {} +
EOF

chmod 750 /usr/local/sbin/respaldo_biblioteca.sh

# 3. Programar tarea diaria a las 02:00 a.m. en crontab de root
(crontab -l 2>/dev/null | grep -v "respaldo_biblioteca.sh" || true; echo "0 2 * * * /usr/local/sbin/respaldo_biblioteca.sh") | crontab -

# 4. Ejecutar un respaldo inmediato de prueba para generar evidencia real
/usr/local/sbin/respaldo_biblioteca.sh

echo ""
echo "=================================================================="
echo " EVIDENCIA 1 (TOMAR CAPTURA): Tarea programada en Crontab (02:00 AM)"
echo " y respaldo incremental verificado en /mnt/respaldo/biblioteca"
echo "=================================================================="
crontab -l
ls -la /mnt/respaldo/biblioteca/
ls -la /mnt/respaldo/biblioteca/ultimo/

echo ""
echo "=================================================================="
echo " EVIDENCIA 2 (TOMAR CAPTURA): Auditoría de Samba (smbstatus y logs)"
echo "=================================================================="
smbstatus
ls -la /var/log/samba/
