#!/bin/bash
# ==============================================================================
# MÓDULO 2 — RESPONSABLE: MATHIAS FABRICIO MARCELO MEGO
# Tema que vas a sustentar el lunes:
#   - Configuración del servidor Samba (/etc/samba/smb.conf) para conectar con Windows
#   - Solución al INCIDENTE 3 (Windows 10 pedía clave en bucle -> tdbsam, Never guest, SMB2_02)
#   - Solución al INCIDENTE 4 (Tesista llenó el disco con videos/ISOs -> veto files)
#   - Papelera de reciclaje automática en Samba (vfs objects = recycle)
# ==============================================================================

echo "=================================================================="
echo " EJECUTANDO MÓDULO 2 (MATHIAS MARCELO) - SAMBA Y CONTROL DE ACCESO"
echo "=================================================================="

export DEBIAN_FRONTEND=noninteractive
apt-get update -y >/dev/null
apt-get install -y samba smbclient >/dev/null

# Aseguramos que las carpetas base y usuarios mínimos existan para probar Samba:
mkdir -p /srv/biblioteca/{publico,departamental,privado,tesis,metadatos}
for g in admin_ti bibliotecarios usuarios_consulta catalogacion consulta; do groupadd -f "$g"; done
for u in carlos alumno01 adq01 tesista01; do id -u "$u" >/dev/null 2>&1 || useradd -m -s /bin/bash "$u"; done

# ------------------------------------------------------------------------------
# PASO 1: Completar los parámetros clave en /etc/samba/smb.conf (Sección 4.4)
# Lee los comentarios con '>>> COMPLETA AQUÍ <<<' dentro del archivo smb.conf
# y reemplaza la palabra PENDIENTE por el valor exacto que indica el comentario:
#   1) En [global]: map to guest = Never          (Bloquea invitados anónimos - Incidente 3)
#   2) En [global]: server min protocol = SMB2_02 (Compatible con Windows 10/11 - Incidente 3)
#   3) En [tesis]:  vfs objects = recycle         (Activa la papelera - Incidente 1)
#   4) En [tesis]:  veto files = /*.iso/*.mp4/*.mkv/*.avi/  (Bloquea videos e ISOs - Incidente 4)
# ------------------------------------------------------------------------------
cat > /etc/samba/smb.conf << 'EOF'
[global]
   workgroup = WORKGROUP
   server string = Servidor de Archivos Biblioteca ABC
   security = user
   passdb backend = tdbsam
   # >>> COMPLETA AQUÍ 1: Cambia PENDIENTE por Never para prohibir el acceso de invitados:
   map to guest = PENDIENTE
   # >>> COMPLETA AQUÍ 2: Cambia PENDIENTE por SMB2_02 para que Windows 10 conecte sin bucle:
   server min protocol = PENDIENTE
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
   # >>> COMPLETA AQUÍ 3: Cambia PENDIENTE por recycle para activar la papelera automática:
   vfs objects = PENDIENTE
   recycle:repository = .papelera/%U
   recycle:keeptree = yes
   recycle:versions = yes
   # >>> COMPLETA AQUÍ 4: Cambia PENDIENTE por /*.iso/*.mp4/*.mkv/*.avi/ para prohibir videos e ISOs:
   veto files = PENDIENTE
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

# ------------------------------------------------------------------------------
# PASO 2: Registrar los usuarios en la base de contraseñas de Samba (tdbsam)
# ¿Por qué? Aunque un usuario exista en Linux, si no lo registras con 'smbpasswd -a',
# Windows 10 entra en un bucle infinito pidiendo contraseña (Incidente 3).
# Ya te dejé registrado a 'carlos' como ejemplo.
# >>> COMPLETA AQUÍ ABAJO agregando a alumno01, adq01 y tesista01 en la lista del for <<<
# ------------------------------------------------------------------------------
CLAVE_DEMO="Biblio2026*"
# Agrega alumno01 adq01 tesista01 después de carlos en la línea de abajo:
for usr in carlos; do
    if id -u "$usr" >/dev/null 2>&1; then
        (echo "$CLAVE_DEMO"; echo "$CLAVE_DEMO") | smbpasswd -s -a "$usr" >/dev/null
        smbpasswd -e "$usr" >/dev/null
    fi
done

# Reiniciar Samba para aplicar los cambios:
service smbd restart 2>/dev/null || /usr/sbin/smbd -D 2>/dev/null || true

# ==============================================================================
# AUTOVERIFICADOR AUTOMÁTICO DE MATHIAS (No borrar esta sección)
# ==============================================================================
echo ""
echo "================= REPORTE DE AVANCE DE MATHIAS ================="
FALLOS=0

if grep -q "map to guest = Never" /etc/samba/smb.conf; then
    echo " [OK] Incidente 3 (Parte A): Invitados bloqueados (map to guest = Never)."
else
    echo " [FALTA] Aún dice PENDIENTE en 'map to guest' dentro de smb.conf (Revisa COMPLETA AQUÍ 1)."
    FALLOS=$((FALLOS+1))
fi

if grep -q "server min protocol = SMB2_02" /etc/samba/smb.conf; then
    echo " [OK] Incidente 3 (Parte B): Protocolo SMB2_02 configurado para Windows 10/11."
else
    echo " [FALTA] Aún dice PENDIENTE en 'server min protocol' (Revisa COMPLETA AQUÍ 2)."
    FALLOS=$((FALLOS+1))
fi

if grep -q "vfs objects = recycle" /etc/samba/smb.conf; then
    echo " [OK] Incidente 1 en Samba: Papelera de reciclaje (recycle) activada en [tesis]."
else
    echo " [FALTA] Aún dice PENDIENTE en 'vfs objects' (Revisa COMPLETA AQUÍ 3)."
    FALLOS=$((FALLOS+1))
fi

if grep -q "veto files = /\*.iso/\*.mp4/\*.mkv/\*.avi/" /etc/samba/smb.conf; then
    echo " [OK] Incidente 4 en Samba: Filtro veto files contra ISOs y videos activado."
else
    echo " [FALTA] Aún dice PENDIENTE en 'veto files' (Revisa COMPLETA AQUÍ 4)."
    FALLOS=$((FALLOS+1))
fi

for u in carlos alumno01 adq01 tesista01; do
    if pdbedit -L 2>/dev/null | grep -q "^$u:"; then
        echo " [OK] Usuario '$u' registrado en la base tdbsam de Samba."
    else
        echo " [FALTA] Falta registrar al usuario '$u' en Samba (Revisa el PASO 2)."
        FALLOS=$((FALLOS+1))
    fi
done

echo "----------------------------------------------------------------"
if [ "$FALLOS" -eq 0 ]; then
    echo " ¡FELICITACIONES MATHIAS! Tu módulo de Samba está 100% completo."
    echo " Toma captura de pantalla de la validación de aquí abajo y haz Commit & Push:"
    testparm -s 2>/dev/null
    pdbedit -L
else
    echo " Tienes $FALLOS punto(s) por completar arriba. ¡Edita el archivo y vuelve a probar!"
fi
