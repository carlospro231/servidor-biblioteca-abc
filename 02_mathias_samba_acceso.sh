#!/bin/bash
# ==============================================================================
# MÓDULO 2 — RESPONSABLE: MATHIAS FABRICIO MARCELO MEGO
# ==============================================================================
# OBJETIVOS A IMPLEMENTAR CON TUS COMANDOS (Secciones 4.4 y 4.5 del Informe):
# 1. Instalar 'samba' y 'smbclient'
# 2. Configurar /etc/samba/smb.conf con:
#    - [global]: map to guest = Never, server min protocol = SMB2_02 (Incidente 3)
#    - Recursos [Publico], [Departamental], [tesis] y [metadatos]
#    - En [tesis]: papelera (vfs objects = recycle) y filtro veto files = /*.iso/*.mp4/*.mkv/*.avi/ (Incidente 4)
#    - En [metadatos]: force group = catalogacion, create mask = 0664, directory mask = 0775, locking = yes
# 3. Registrar las contraseñas de los usuarios en Samba (smbpasswd -a) y reiniciar smbd
# 4. Validar la configuración con testparm -s y pdbedit -L
# ==============================================================================

# Escribe tus comandos aquí abajo:

