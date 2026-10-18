#!/bin/bash
# MÓDULO 3 — RESPALDO INCREMENTAL AUTOMÁTICO (rsync + cron 02:00 AM) Y AUDITORÍA
export DEBIAN_FRONTEND=noninteractive
apt-get install -y rsync cron >/dev/null

mkdir -p /mnt/respaldo/biblioteca

cat > /usr/local/sbin/respaldo_biblioteca.sh << 'BKP'
#!/bin/bash
DEST="/mnt/respaldo/biblioteca"
HOY=$(date +%F)
mkdir -p "$DEST"

if [ -d "$DEST/ultimo" ]; then
    rsync -aHAX --delete --link-dest="$DEST/ultimo" /srv/biblioteca/ "$DEST/$HOY/" >> /var/log/respaldo.log 2>&1 \
      && ln -sfn "$DEST/$HOY" "$DEST/ultimo"
else
    rsync -aHAX --delete /srv/biblioteca/ "$DEST/$HOY/" >> /var/log/respaldo.log 2>&1 \
      && ln -sfn "$DEST/$HOY" "$DEST/ultimo"
fi

find "$DEST" -mindepth 1 -maxdepth 1 -type d -mtime +30 -exec rm -rf {} +
BKP

chmod 750 /usr/local/sbin/respaldo_biblioteca.sh
(crontab -l 2>/dev/null | grep -v "respaldo_biblioteca.sh" || true; echo "0 2 * * * /usr/local/sbin/respaldo_biblioteca.sh") | crontab -
/usr/local/sbin/respaldo_biblioteca.sh
