#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="${SCRIPT_DIR}/.backup"

remove_hidden_files() {
	echo "Eliminando archivos ocultos en ${BACKUP_DIR}, excepto .git..."
	
	# Usar find para eliminar archivos ocultos directamente en BACKUP_DIR
	find "${BACKUP_DIR}" -maxdepth 1 -name ".*" -type f ! -name ".git" -exec rm -f {} \;
	
	# Verificar si la eliminación fue exitosa
	if [ $? -eq 0 ]; then
		echo "Archivos ocultos eliminados correctamente."
	else
		echo "Hubo un problema al eliminar los archivos ocultos."
		return 1
	fi
}

remove_hidden_files 