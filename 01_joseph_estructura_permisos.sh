#!/bin/bash
# MÓDULO 1 — ESTRUCTURA FHS, GRUPOS RBAC, USUARIOS Y PERMISOS 3775/2775
mkdir -p /srv/biblioteca/{publico,departamental,privado,tesis,metadatos}

for g in admin_ti bibliotecarios usuarios_consulta catalogacion consulta; do
    groupadd -f "$g"
done

id -u carlos >/dev/null 2>&1 || useradd -m -g bibliotecarios -s /bin/bash carlos
usermod -aG catalogacion,admin_ti carlos

id -u alumno01 >/dev/null 2>&1 || useradd -m -g consulta -s /bin/bash alumno01
usermod -aG usuarios_consulta alumno01

for u in cat01 cat02; do
    id -u "$u" >/dev/null 2>&1 || useradd -m -g catalogacion -s /bin/bash "$u"
done

id -u adq01 >/dev/null 2>&1 || useradd -m -g bibliotecarios -s /bin/bash adq01
id -u tesista01 >/dev/null 2>&1 || useradd -m -g consulta -s /bin/bash tesista01

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

# Archivos de prueba para la demostración del lunes
echo "Tesis Digitalizada 2026 - FIEE UNMSM" > /srv/biblioteca/tesis/tesis_fiee_2026.pdf
chown carlos:catalogacion /srv/biblioteca/tesis/tesis_fiee_2026.pdf
chmod 664 /srv/biblioteca/tesis/tesis_fiee_2026.pdf

echo "Catalogo General Biblioteca ABC" > /srv/biblioteca/metadatos/catalogo_general.csv
chown cat01:catalogacion /srv/biblioteca/metadatos/catalogo_general.csv
chmod 664 /srv/biblioteca/metadatos/catalogo_general.csv

echo "Reglamento de Sala de Lectura" > /srv/biblioteca/publico/reglamento.txt
chmod 664 /srv/biblioteca/publico/reglamento.txt
