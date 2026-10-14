#!/bin/bash
# ==============================================================================
# MÓDULO 3 — RESPONSABLE: FRANCO ANTONIO GAMARRA PAICO
# Tema que vas a sustentar el lunes:
#   - Solución al INCIDENTE 6 (Temor de la Jefa de Biblioteca a perder años de
#     tesis digitalizadas si falla el servidor)
#   - Respaldo automático incremental con 'rsync' y enlaces duros (--link-dest)
#   - Programación nocturna a las 02:00 a.m. con 'crontab' y auditoría 'smbstatus'
# ==============================================================================

echo "=================================================================="
echo " EJECUTANDO MÓDULO 3 (FRANCO GAMARRA) - RESPALDOS Y AUDITORÍA"
echo "=================================================================="

export DEBIAN_FRONTEND=noninteractive
apt-get update -y >/dev/null
apt-get install -y rsync cron >/dev/null

# Aseguramos que exista contenido en /srv/biblioteca para respaldar:
mkdir -p /srv/biblioteca/tesis
echo "Tesis Digitalizada 2026 - FIEE UNMSM" > /srv/biblioteca/tesis/tesis_fiee_2026.pdf

# ------------------------------------------------------------------------------
# PASO 1: Crear el directorio de destino donde se guardarán las copias de seguridad
# Según la Sección 5.2 del Informe, la ruta de respaldo es: /mnt/respaldo/biblioteca
# >>> COMPLETA AQUÍ ABAJO el comando mkdir -p para crear /mnt/respaldo/biblioteca <<<
# ------------------------------------------------------------------------------
# Escribe aquí: mkdir -p /mnt/respaldo/biblioteca



# ------------------------------------------------------------------------------
# PASO 2: Crear el script de respaldo incremental /usr/local/sbin/respaldo_biblioteca.sh
# ¿Qué hace este script? Copia /srv/biblioteca/ hacia /mnt/respaldo/biblioteca/FECHA
# conservando permisos (-aHAX) y borrando copias de más de 30 días.
# >>> COMPLETA AQUÍ ABAJO asignando permiso de ejecución (chmod 750) al script <<<
# ------------------------------------------------------------------------------
cat > /usr/local/sbin/respaldo_biblioteca.sh << 'EOF'
#!/bin/bash
DEST="/mnt/respaldo/biblioteca"
HOY=$(date +%F)

if [ ! -d "$DEST" ]; then
    exit 1
fi

if [ -d "$DEST/ultimo" ]; then
    rsync -aHAX --delete --link-dest="$DEST/ultimo" /srv/biblioteca/ "$DEST/$HOY/" >> /var/log/respaldo.log 2>&1       && ln -sfn "$DEST/$HOY" "$DEST/ultimo"
else
    rsync -aHAX --delete /srv/biblioteca/ "$DEST/$HOY/" >> /var/log/respaldo.log 2>&1       && ln -sfn "$DEST/$HOY" "$DEST/ultimo"
fi

# Política de retención: elimina respaldos de más de 30 días
find "$DEST" -mindepth 1 -maxdepth 1 -type d -mtime +30 -exec rm -rf {} +
EOF

# Escribe aquí abajo el comando: chmod 750 /usr/local/sbin/respaldo_biblioteca.sh



# ------------------------------------------------------------------------------
# PASO 3: Programar el respaldo automático todos los días a las 02:00 a.m. en Crontab
# En cron, el formato es: MINUTO HORA DÍA_MES MES DÍA_SEMANA COMANDO
# Para las 2:00 a.m. todos los días se escribe: 0 2 * * *
# >>> COMPLETA AQUÍ ABAJO cambiando PENDIENTE por: 0 2 * * * <<<
# ------------------------------------------------------------------------------
REGLA_CRON="PENDIENTE /usr/local/sbin/respaldo_biblioteca.sh"

if [[ "$REGLA_CRON" != *"PENDIENTE"* ]]; then
    (crontab -l 2>/dev/null | grep -v "respaldo_biblioteca.sh" || true; echo "$REGLA_CRON") | crontab -
fi

# Ejecutamos el script de respaldo si ya tiene permisos 750:
if [ -x /usr/local/sbin/respaldo_biblioteca.sh ]; then
    /usr/local/sbin/respaldo_biblioteca.sh || true
fi

# ==============================================================================
# AUTOVERIFICADOR AUTOMÁTICO DE FRANCO (No borrar esta sección)
# ==============================================================================
echo ""
echo "================= REPORTE DE AVANCE DE FRANCO ================="
FALLOS=0

if [ -d /mnt/respaldo/biblioteca ]; then
    echo " [OK] PASO 1: Carpeta /mnt/respaldo/biblioteca creada."
else
    echo " [FALTA] PASO 1: Falta crear la carpeta /mnt/respaldo/biblioteca."
    FALLOS=$((FALLOS+1))
fi

PERM_SCRIPT=$(stat -c "%a" /usr/local/sbin/respaldo_biblioteca.sh 2>/dev/null || echo "0")
if [ "$PERM_SCRIPT" = "750" ]; then
    echo " [OK] PASO 2: Script /usr/local/sbin/respaldo_biblioteca.sh tiene permiso 750."
else
    echo " [FALTA] PASO 2: El script tiene permiso $PERM_SCRIPT en vez de 750 (Falta chmod 750)."
    FALLOS=$((FALLOS+1))
fi

if crontab -l 2>/dev/null | grep -q "^0 2 \* \* \* /usr/local/sbin/respaldo_biblioteca.sh"; then
    echo " [OK] PASO 3: Tarea programada en Crontab a las 02:00 a.m. (0 2 * * *)."
else
    echo " [FALTA] PASO 3: Aún dice PENDIENTE en REGLA_CRON (Cambia PENDIENTE por: 0 2 * * *)."
    FALLOS=$((FALLOS+1))
fi

if [ -L /mnt/respaldo/biblioteca/ultimo ]; then
    echo " [OK] Incidente 6 resuelto: El respaldo incremental se ejecutó y creó /mnt/respaldo/biblioteca/ultimo."
else
    echo " [FALTA] Aún no se generó el respaldo en /mnt/respaldo/biblioteca/ultimo."
    FALLOS=$((FALLOS+1))
fi

echo "---------------------------------------------------------------"
if [ "$FALLOS" -eq 0 ]; then
    echo " ¡FELICITACIONES FRANCO! Tu módulo de Backups y Auditoría está 100% completo."
    echo " Toma captura de pantalla de las evidencias de aquí abajo y haz Commit & Push:"
    crontab -l
    ls -la /mnt/respaldo/biblioteca/
    ls -la /mnt/respaldo/biblioteca/ultimo/
    smbstatus 2>/dev/null || true
else
    echo " Tienes $FALLOS punto(s) por completar arriba. ¡Edita el archivo y vuelve a probar!"
fi
