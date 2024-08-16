#!/bin/bash

# Configura estas variables según tus necesidades
BASE_DIR="$HOME/dev/🍎/pocs"
BACKUP_DIR="$HOME/dev/🍎/.pocs-backup"
REMOTE_REPO_URL="git@github.com:crisrojas/SDD-Pocs.git"
REPO_NAME="SDD-Pocs"

# Función para eliminar archivos ocultos en la raíz
remove_hidden_files() {
    echo "Eliminando archivos ocultos en la raíz del directorio ${1}, excepto .git..."
    # Navegar al directorio de respaldo antes de eliminar archivos ocultos
    cd "${1}" || { echo "No se pudo cambiar al directorio ${1}. Verifica que el directorio exista y los permisos."; exit 1; }
    # Eliminar solo archivos ocultos en la raíz, excluyendo la carpeta .git
    find . -maxdepth 1 -name ".*" -type f ! -name ".git" -exec rm -f {} +
}


# Verificar si el directorio de respaldo existe
if [ -d "${BACKUP_DIR}" ]; then
    echo "El directorio de respaldo existe. Sincronizando con rsync..."
    
    # Sincronizar el directorio de respaldo existente con la carpeta de trabajo
    rsync -a --exclude='.git' "${BASE_DIR}/" "${BACKUP_DIR}/"

    # Verificar si la sincronización fue exitosa
    if [ $? -ne 0 ]; then
        echo "Error al sincronizar archivos con rsync."
        exit 1
    fi

    # Eliminar archivos ocultos en la raíz del directorio de respaldo
    remove_hidden_files "${BACKUP_DIR}"

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
    rsync -a --exclude='.git' "${BASE_DIR}/" "${BACKUP_DIR}/"

    # Verificar si la sincronización fue exitosa
    if [ $? -ne 0 ]; then
        echo "Error al copiar archivos con rsync."
        exit 1
    fi

    # Eliminar archivos ocultos en la raíz del directorio de respaldo
    remove_hidden_files "${BACKUP_DIR}"

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