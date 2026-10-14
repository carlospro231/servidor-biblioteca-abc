#!/bin/bash
# ==============================================================================
# MÓDULO 1 — RESPONSABLE: JOSEPH PATRICK GOMERO MENDOZA
# ==============================================================================
# OBJETIVOS A IMPLEMENTAR CON TUS COMANDOS (Secciones 4.2 y 4.3 del Informe):
# 1. Crear las 5 carpetas en /srv/biblioteca/: publico, departamental, privado, tesis, metadatos
# 2. Crear los grupos RBAC: admin_ti, bibliotecarios, usuarios_consulta, catalogacion, consulta
# 3. Crear los usuarios: carlos, alumno01, cat01, cat02, adq01, tesista01 y asignarlos a sus grupos
# 4. Asignar dueños (chown) y permisos (chmod):
#    - departamental (770), publico (775), privado (770)
#    - tesis (3775 -> SGID + Sticky Bit para resolver Incidente 1)
#    - metadatos (2775 -> SGID para resolver Incidente 2)
# 5. Crear archivos de prueba dentro de 'tesis' y 'metadatos'
# ==============================================================================

# Escribe tus comandos aquí abajo:

