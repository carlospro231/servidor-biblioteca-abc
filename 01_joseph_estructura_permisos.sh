#!/bin/bash
# ==============================================================================
# MÓDULO 1 — RESPONSABLE: JOSEPH PATRICK GOMERO MENDOZA
# Objetivo: Estructura FHS (/srv/biblioteca), Grupos RBAC, Usuarios y Permisos
#           POSIX Especiales (SGID 2775 y Sticky Bit 3775 — Incidentes 1 y 2)
# ==============================================================================
set -e

echo "=================================================================="
echo " [MÓDULO 1 - JOSEPH GOMERO] Iniciando creación de estructura FHS"
echo "=================================================================="

# 1. Creación de la jerarquía de directorios bajo /srv/biblioteca/ (RF-05)
mkdir -p /srv/biblioteca/publico
mkdir -p /srv/biblioteca/departamental
mkdir -p /srv/biblioteca/privado
mkdir -p /srv/biblioteca/tesis
mkdir -p /srv/biblioteca/metadatos

# 2. Creación de grupos según Control de Acceso Basado en Roles - RBAC (RF-02)
for grupo in admin_ti bibliotecarios usuarios_consulta catalogacion consulta hemeroteca; do
    getent group "$grupo" >/dev/null || groupadd "$grupo"
done

# 3. Creación de usuarios de prueba de la Biblioteca ABC (RF-01)
id -u carlos >/dev/null 2>&1 || useradd -m -g bibliotecarios -s /bin/bash carlos
usermod -aG catalogacion,admin_ti carlos

id -u alumno01 >/dev/null 2>&1 || useradd -m -g consulta -s /bin/bash alumno01
usermod -aG usuarios_consulta alumno01

id -u cat01 >/dev/null 2>&1 || useradd -m -g catalogacion -s /bin/bash cat01
id -u cat02 >/dev/null 2>&1 || useradd -m -g catalogacion -s /bin/bash cat02
id -u adq01 >/dev/null 2>&1 || useradd -m -g bibliotecarios -s /bin/bash adq01
id -u tesista01 >/dev/null 2>&1 || useradd -m -g consulta -s /bin/bash tesista01

# 4. Asignación de propietarios y permisos POSIX avanzados (RF-03)
# Departamental (770: solo bibliotecarios y root)
chown -R root:bibliotecarios /srv/biblioteca/departamental
chmod -R 770 /srv/biblioteca/departamental

# Público (775: lectura general, escritura para grupo)
chown -R root:usuarios_consulta /srv/biblioteca/publico
chmod -R 775 /srv/biblioteca/publico

# Privado (700: exclusivo administración)
chown -R root:admin_ti /srv/biblioteca/privado
chmod -R 770 /srv/biblioteca/privado

# INCIDENTE 1: Tesis protegidas con SGID + Sticky Bit (3775)
# Evita que usuarios ajenos borren tesis digitalizadas
chown -R root:catalogacion /srv/biblioteca/tesis
chmod 3775 /srv/biblioteca/tesis

# INCIDENTE 2: Metadatos colaborativos con SGID (2775)
# Fuerza que todo archivo nuevo herede el grupo 'catalogacion'
chown -R root:catalogacion /srv/biblioteca/metadatos
chmod 2775 /srv/biblioteca/metadatos

# 5. Creación de archivos académicos de prueba para demostrar en vivo
echo "Tesis Digitalizada 2026 - Ingenieria Electronica UNMSM" > /srv/biblioteca/tesis/tesis_fiee_2026.pdf
chown carlos:catalogacion /srv/biblioteca/tesis/tesis_fiee_2026.pdf
chmod 664 /srv/biblioteca/tesis/tesis_fiee_2026.pdf

echo "Catalogo MARC21 - Acervo Bibliografico Central ABC" > /srv/biblioteca/metadatos/catalogo_general.csv
chown cat01:catalogacion /srv/biblioteca/metadatos/catalogo_general.csv
chmod 664 /srv/biblioteca/metadatos/catalogo_general.csv

echo "Reglamento de Sala de Lectura - Biblioteca ABC" > /srv/biblioteca/publico/reglamento_biblioteca.txt
chmod 664 /srv/biblioteca/publico/reglamento_biblioteca.txt

echo ""
echo "=================================================================="
echo " EVIDENCIA 1 (TOMAR CAPTURA): Estructura y Permisos (3775 y 2775)"
echo "=================================================================="
ls -ld /srv/biblioteca/*

echo ""
echo "=================================================================="
echo " EVIDENCIA 2 (TOMAR CAPTURA): Grupos RBAC y Archivos de Prueba"
echo "=================================================================="
getent group admin_ti bibliotecarios usuarios_consulta catalogacion consulta
ls -la /srv/biblioteca/tesis /srv/biblioteca/metadatos
