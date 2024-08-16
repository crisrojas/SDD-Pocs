#!/bin/bash

# Obtener el directorio en el que se encuentra el script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

BASE_DIR="${SCRIPT_DIR}"
BACKUP_DIR="${SCRIPT_DIR}/.backup"
REMOTE_REPO_URL="git@github.com:crisrojas/SDD-Pocs.git"
REPO_NAME="SDD-Pocs"

# Función para eliminar archivos ocultos en la raíz
# @todo: no funciona
remove_hidden_files() {
    find "${BACKUP_DIR}" -maxdepth 1 -name ".*" -type f -exec rm -f {} +
}


# Verificar si el directorio de respaldo existe
if [ -d "${BACKUP_DIR}" ]; then
    echo "El directorio de respaldo existe. Sincronizando con rsync..."
    
    # Sincronizar el directorio source con la carpeta de destino
    # Y excluye la propia carpeta de destino de la sincronización (por estar dentro de la de fuentes)
    rsync -a --exclude='.git' --exclude='.backup' "${BASE_DIR}/" "${BACKUP_DIR}/"

    # Verificar si la sincronización fue exitosa
    if [ $? -ne 0 ]; then
        echo "Error al sincronizar archivos con rsync."
        exit 1
    fi

    remove_hidden_files

    # Inicializar un repositorio Git si no existe
    cd "${BACKUP_DIR}" || { echo "No se pudo cambiar al directorio ${BACKUP_DIR}. Verifica que el directorio exista."; exit 1; }
    if [ ! -d ".git" ]; then
        echo "Inicializando un nuevo repositorio Git..."
        git init
        git remote add origin "${REMOTE_REPO_URL}"
        git branch -M main
    fi

    # Hacer commit de los cambios con la fecha
    DATE=$(date +%F)
    COMMIT_MESSAGE="${DATE} Backup de POCs"
    git add .
    git commit -m "${COMMIT_MESSAGE}"
    
    # Hacer un push normal para actualizar el repositorio remoto
    echo "Haciendo push de los cambios al repositorio remoto..."
    git push -u origin main

else
    echo "El directorio de respaldo no existe. Creando y configurando el repositorio..."

    # Crear el directorio de respaldo
    mkdir -p "${BACKUP_DIR}"

    # Verificar si el directorio de respaldo se creó correctamente
    if [ $? -ne 0 ]; then
        echo "Error al crear el directorio ${BACKUP_DIR}. Verifica los permisos."
        exit 1
    fi

    # Copiar archivos desde BASE_DIR a BACKUP_DIR
    rsync -a --exclude='.git' --exclude='.backup' "${BASE_DIR}/" "${BACKUP_DIR}/"

    # Verificar si la sincronización fue exitosa
    if [ $? -ne 0 ]; then
        echo "Error al copiar archivos con rsync."
        exit 1
    fi

    remove_hidden_files

    # Inicializar un nuevo repositorio Git en BACKUP_DIR
    cd "${BACKUP_DIR}" || { echo "No se pudo cambiar al directorio ${BACKUP_DIR}. Verifica que el directorio exista."; exit 1; }
    git init
    git add .
    
    # Obtener la fecha actual en formato YYYY-MM-DD
    DATE=$(date +%F)
    COMMIT_MESSAGE="${DATE} Backup de POCs"
    git commit -m "${COMMIT_MESSAGE}"

    # Agregar el repositorio remoto y hacer push forzado
    git remote add origin "${REMOTE_REPO_URL}"
    git branch -M main
    echo "Haciendo push forzado al repositorio remoto..."
    git push --force -u origin main

fi

echo "Respaldo completado."