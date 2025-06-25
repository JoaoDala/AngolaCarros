#!/bin/bash

# backup.sh - Módulo de backup de dados de vendas

DIRETORIO_BACKUP="./backups"
ARQUIVO_VENDAS="vendas.txt"

function criar_diretorio_backup() {
    if [ ! -d "$DIRETORIO_BACKUP" ]; then
        mkdir -p "$DIRETORIO_BACKUP"
        echo "Diretório de backup criado: $DIRETORIO_BACKUP"
    fi
}

function realizar_backup_vendas() {
    criar_diretorio_backup
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    NOME_ARQUIVO_BACKUP="vendas_backup_${TIMESTAMP}.tar.gz"

    if [ -f "$ARQUIVO_VENDAS" ]; then
        tar -czvf "$DIRETORIO_BACKUP/$NOME_ARQUIVO_BACKUP" "$ARQUIVO_VENDAS"
        echo "Backup de vendas realizado com sucesso em: $DIRETORIO_BACKUP/$NOME_ARQUIVO_BACKUP"
    else
        echo "Erro: Arquivo de vendas ($ARQUIVO_VENDAS) não encontrado para backup."
    fi
}

function listar_backups() {
    echo "\n--- Backups Disponíveis ---"
    if [ -d "$DIRETORIO_BACKUP" ] && [ "$(ls -A $DIRETORIO_BACKUP)" ]; then
        ls -lh "$DIRETORIO_BACKUP"
    else
        echo "Nenhum backup encontrado."
    fi
}

function restaurar_backup() {
    echo "\n--- Restaurar Backup ---"
    listar_backups
    read -p "Digite o nome completo do arquivo de backup para restaurar: " arquivo_restaurar

    if [ -f "$DIRETORIO_BACKUP/$arquivo_restaurar" ]; then
        echo "Restaurando $arquivo_restaurar..."
        tar -xzvf "$DIRETORIO_BACKUP/$arquivo_restaurar" -C .
        echo "Backup restaurado com sucesso!"
    else
        echo "Erro: Arquivo de backup não encontrado."
    fi
}

function menu_backup() {
    while true;
    do
        clear
        echo "=============================================="
        echo "           Módulo de Backup de Dados          "
        echo "=============================================="
        echo "1. Realizar Backup de Vendas"
        echo "2. Listar Backups"
        echo "3. Restaurar Backup"
        echo "0. Voltar ao Menu Principal"
        echo "=============================================="
        read -p "Escolha uma opção: " opcao_backup

        case $opcao_backup in
            1) realizar_backup_vendas ;;
            2) listar_backups ;;
            3) restaurar_backup ;;
            0) break ;;
            *)
                echo "Opção inválida. Por favor, escolha uma opção válida."
                ;;
        esac
        read -p "Pressione Enter para continuar..."
    done
}

# Chama o menu de backup se o script for executado diretamente
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    menu_backup
fi


