cat > 01_joseph_estructura_permisos.sh << 'EOF'
#!/bin/bash
# 1. Crear las 5 carpetas bajo el estándar FHS (/srv/biblioteca/)
mkdir -p /srv/biblioteca/publico
mkdir -p /srv/biblioteca/departamental
mkdir -p /srv/biblioteca/privado
mkdir -p /srv/biblioteca/tesis
mkdir -p /srv/biblioteca/metadatos

# 2. Crear los 5 grupos del modelo RBAC
groupadd -f admin_ti
groupadd -f bibliotecarios
groupadd -f usuarios_consulta
groupadd -f catalogacion
groupadd -f consulta

# 3. Crear los usuarios de la biblioteca y asignarlos a sus roles
id -u carlos >/dev/null 2>&1 || useradd -m -g bibliotecarios -s /bin/bash carlos
usermod -aG catalogacion,admin_ti carlos
id -u alumno01 >/dev/null 2>&1 || useradd -m -g consulta -s /bin/bash alumno01
usermod -aG usuarios_consulta alumno01
id -u cat01 >/dev/null 2>&1 || useradd -m -g catalogacion -s /bin/bash cat01
id -u cat02 >/dev/null 2>&1 || useradd -m -g catalogacion -s /bin/bash cat02
id -u adq01 >/dev/null 2>&1 || useradd -m -g bibliotecarios -s /bin/bash adq01
id -u tesista01 >/dev/null 2>&1 || useradd -m -g consulta -s /bin/bash tesista01

# 4. Asignar propietarios (chown) y permisos POSIX normales y especiales (chmod)
chown -R root:bibliotecarios /srv/biblioteca/departamental
chmod -R 770 /srv/biblioteca/departamental
chown -R root:usuarios_consulta /srv/biblioteca/publico
chmod -R 775 /srv/biblioteca/publico
chown -R root:admin_ti /srv/biblioteca/privado
chmod -R 770 /srv/biblioteca/privado

# Incidente 1: SGID + Sticky Bit (3775) en tesis
chown -R root:catalogacion /srv/biblioteca/tesis
chmod 3775 /srv/biblioteca/tesis

# Incidente 2: SGID (2775) en metadatos
chown -R root:catalogacion /srv/biblioteca/metadatos
chmod 2775 /srv/biblioteca/metadatos

# 5. Archivos de prueba para la demostración en vivo
echo "Tesis Digitalizada 2026 - FIEE UNMSM" > /srv/biblioteca/tesis/tesis_fiee_2026.pdf
chown carlos:catalogacion /srv/biblioteca/tesis/tesis_fiee_2026.pdf
chmod 664 /srv/biblioteca/tesis/tesis_fiee_2026.pdf
echo "Catalogo MARC21 Biblioteca ABC" > /srv/biblioteca/metadatos/catalogo_general.csv
chown cat01:catalogacion /srv/biblioteca/metadatos/catalogo_general.csv
chmod 664 /srv/biblioteca/metadatos/catalogo_general.csv
EOF

sudo bash 04_carlos_seguridad_vmware.sh

git add 01_joseph_estructura_permisos.sh
git commit -m "Modulo 1 Completado y Verificado"
git push
