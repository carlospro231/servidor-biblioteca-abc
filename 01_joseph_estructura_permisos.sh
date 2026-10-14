#!/bin/bash
# ==============================================================================
# MÓDULO 1 — RESPONSABLE: JOSEPH PATRICK GOMERO MENDOZA
# Tema que vas a sustentar el lunes:
#   - Cómo se organizan las carpetas del servidor según el estándar FHS (/srv/biblioteca)
#   - Control de acceso por roles (RBAC: grupos y usuarios)
#   - Solución al INCIDENTE 1 (Alumno borró tesis por error -> Sticky Bit 3775)
#   - Solución al INCIDENTE 2 (Catalogadoras no podían editar juntas -> SGID 2775)
# ==============================================================================

echo "=================================================================="
echo " EJECUTANDO MÓDULO 1 (JOSEPH GOMERO) - ESTRUCTURA Y PERMISOS"
echo "=================================================================="

# ------------------------------------------------------------------------------
# PASO 1: Crear las 5 carpetas del servidor bajo /srv/biblioteca/ (Sección 4.2)
# ¿Por qué en /srv? Porque en Linux el estándar FHS define /srv para los datos
# que el servidor comparte en la red.
# Ya te dejé creada la carpeta 'publico' como ejemplo.
# >>> COMPLETA AQUÍ ABAJO los 4 comandos mkdir -p para crear:
#     departamental, privado, tesis y metadatos <<<
# ------------------------------------------------------------------------------
mkdir -p /srv/biblioteca/publico
# Escribe aquí tus 4 comandos mkdir -p:




# ------------------------------------------------------------------------------
# PASO 2: Crear los 5 grupos de trabajo según su rol - RBAC (Sección 4.2)
# Usamos 'groupadd -f' para crear el grupo sin dar error si ya existe.
# Ya te dejé 'admin_ti' como ejemplo.
# >>> COMPLETA AQUÍ ABAJO los comandos groupadd -f para crear los grupos:
#     bibliotecarios, usuarios_consulta, catalogacion y consulta <<<
# ------------------------------------------------------------------------------
groupadd -f admin_ti
# Escribe aquí tus 4 comandos groupadd -f:




# ------------------------------------------------------------------------------
# PASO 3: Crear los usuarios de la biblioteca (Sección 4.5)
# Ya están creados de ejemplo 'carlos' (bibliotecario/catalogador) y 'alumno01' (consulta).
# >>> COMPLETA AQUÍ ABAJO para crear a las dos catalogadoras ('cat01' y 'cat02' en el
#     grupo 'catalogacion'), a 'adq01' (grupo 'bibliotecarios') y a 'tesista01' (grupo 'consulta') <<<
# ------------------------------------------------------------------------------
id -u carlos >/dev/null 2>&1 || useradd -m -g bibliotecarios -s /bin/bash carlos
usermod -aG catalogacion,admin_ti carlos 2>/dev/null || true

id -u alumno01 >/dev/null 2>&1 || useradd -m -g consulta -s /bin/bash alumno01
usermod -aG usuarios_consulta alumno01 2>/dev/null || true

# Escribe aquí los comandos para crear a cat01, cat02, adq01 y tesista01 (guíate del ejemplo de arriba):




# ------------------------------------------------------------------------------
# PASO 4: Permisos de Departamental (770) y Público (775) (Sección 4.3)
# - 770 en departamental: Solo el dueño (root) y el grupo 'bibliotecarios' entran; otros = 0.
# - 775 en publico: Todos pueden leer, pero solo el grupo escribe.
# >>> COMPLETA AQUÍ ABAJO el chmod 775 para /srv/biblioteca/publico <<<
# ------------------------------------------------------------------------------
chown -R root:bibliotecarios /srv/biblioteca/departamental 2>/dev/null || true
chmod -R 770 /srv/biblioteca/departamental 2>/dev/null || true

chown -R root:usuarios_consulta /srv/biblioteca/publico 2>/dev/null || true
# Escribe aquí el comando chmod -R 775 para /srv/biblioteca/publico:



# ------------------------------------------------------------------------------
# PASO 5: RESOLVER INCIDENTE 1 Y 2 CON PERMISOS ESPECIALES (3775 y 2775)
# - INCIDENTE 1 (Tesis): Un alumno borró las tesis. Ponemos permiso 3775 a /srv/biblioteca/tesis
#   (El '3' adelante suma SGID=2 + Sticky Bit=1, para que nadie borre archivos ajenos).
# - INCIDENTE 2 (Metadatos): Dos catalogadoras se bloqueaban al editar. Ponemos permiso 2775
#   a /srv/biblioteca/metadatos (El '2' adelante es SGID: todo archivo nuevo hereda el grupo 'catalogacion').
# >>> COMPLETA AQUÍ ABAJO los dos comandos chmod (3775 para tesis y 2775 para metadatos) <<<
# ------------------------------------------------------------------------------
chown -R root:catalogacion /srv/biblioteca/tesis 2>/dev/null || true
# Escribe aquí: chmod 3775 /srv/biblioteca/tesis


chown -R root:catalogacion /srv/biblioteca/metadatos 2>/dev/null || true
# Escribe aquí: chmod 2775 /srv/biblioteca/metadatos


# Creación automática de archivos de prueba para la demostración del lunes:
if [ -d /srv/biblioteca/tesis ]; then
    echo "Tesis Digitalizada 2026 - FIEE UNMSM" > /srv/biblioteca/tesis/tesis_fiee_2026.pdf
    chown carlos:catalogacion /srv/biblioteca/tesis/tesis_fiee_2026.pdf 2>/dev/null || true
    chmod 664 /srv/biblioteca/tesis/tesis_fiee_2026.pdf 2>/dev/null || true
fi
if [ -d /srv/biblioteca/metadatos ]; then
    echo "Catalogo Bibliografico ABC" > /srv/biblioteca/metadatos/catalogo_general.csv
    chmod 664 /srv/biblioteca/metadatos/catalogo_general.csv 2>/dev/null || true
fi

# ==============================================================================
# AUTOVERIFICADOR AUTOMÁTICO DE JOSEPH (No borrar esta sección)
# ==============================================================================
echo ""
echo "================= REPORTE DE AVANCE DE JOSEPH ================="
FALLOS=0
for dir in publico departamental privado tesis metadatos; do
    if [ -d "/srv/biblioteca/$dir" ]; then
        echo " [OK] Carpeta /srv/biblioteca/$dir creada correctamente."
    else
        echo " [FALTA] Falta crear la carpeta /srv/biblioteca/$dir (Revisa el PASO 1)."
        FALLOS=$((FALLOS+1))
    fi
done

for grp in admin_ti bibliotecarios usuarios_consulta catalogacion consulta; do
    if getent group "$grp" >/dev/null; then
        echo " [OK] Grupo RBAC '$grp' existe."
    else
        echo " [FALTA] Falta crear el grupo '$grp' (Revisa el PASO 2)."
        FALLOS=$((FALLOS+1))
    fi
done

for usr in carlos alumno01 cat01 cat02 adq01 tesista01; do
    if id -u "$usr" >/dev/null 2>&1; then
        echo " [OK] Usuario '$usr' creado."
    else
        echo " [FALTA] Falta crear el usuario '$usr' (Revisa el PASO 3)."
        FALLOS=$((FALLOS+1))
    fi
done

PERM_TESIS=$(stat -c "%a" /srv/biblioteca/tesis 2>/dev/null || echo "0")
if [ "$PERM_TESIS" = "3775" ]; then
    echo " [OK] Incidente 1 resuelto: /srv/biblioteca/tesis tiene Sticky Bit + SGID (3775)."
else
    echo " [FALTA] /srv/biblioteca/tesis tiene permiso $PERM_TESIS en vez de 3775 (Revisa el PASO 5)."
    FALLOS=$((FALLOS+1))
fi

PERM_META=$(stat -c "%a" /srv/biblioteca/metadatos 2>/dev/null || echo "0")
if [ "$PERM_META" = "2775" ]; then
    echo " [OK] Incidente 2 resuelto: /srv/biblioteca/metadatos tiene SGID (2775)."
else
    echo " [FALTA] /srv/biblioteca/metadatos tiene permiso $PERM_META en vez de 2775 (Revisa el PASO 5)."
    FALLOS=$((FALLOS+1))
fi

echo "---------------------------------------------------------------"
if [ "$FALLOS" -eq 0 ]; then
    echo " ¡FELICITACIONES JOSEPH! Tu módulo está 100% completo."
    echo " Toma captura de las líneas de aquí abajo y haz Commit & Push:"
    ls -ld /srv/biblioteca/*
else
    echo " Tienes $FALLOS punto(s) por completar arriba. ¡Edita el archivo y vuelve a probar!"
fi
