#!/bin/bash

# logs.sh - Módulo de gestão de logs

DIRETORIO_LOGS="./logs"

function inicializar_diretorio_logs() {
    if [ ! -d "$DIRETORIO_LOGS" ]; then
        mkdir -p "$DIRETORIO_LOGS"
        echo "Diretório de logs criado: $DIRETORIO_LOGS"
    fi
}

function registrar_log() {
    inicializar_diretorio_logs
    local tipo_log=$1
    local mensagem=$2
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] [$tipo_log] $mensagem" >> "$DIRETORIO_LOGS/sistema.log"
}

function visualizar_logs() {
    echo "\n--- Visualizar Logs do Sistema ---"
    if [ -f "$DIRETORIO_LOGS/sistema.log" ]; then
        cat "$DIRETORIO_LOGS/sistema.log"
    else
        echo "Nenhum log registado ainda."
    fi
}

function limpar_logs() {
    echo "\n--- Limpar Logs do Sistema ---"
    if [ -f "$DIRETORIO_LOGS/sistema.log" ]; then
        > "$DIRETORIO_LOGS/sistema.log"
        echo "Logs do sistema limpos com sucesso!"
    else
        echo "Nenhum log para limpar."
    fi
}

function menu_logs() {
    while true;
    do
        clear
        echo "=============================================="
        echo "            Módulo de Gestão de Logs          "
        echo "=============================================="
        echo "1. Visualizar Logs"
        echo "2. Limpar Logs"
        echo "0. Voltar ao Menu Principal"
        echo "=============================================="
        read -p "Escolha uma opção: " opcao_logs

        case $opcao_logs in
            1) visualizar_logs ;;
            2) limpar_logs ;;
            0) break ;;
            *)
                echo "Opção inválida. Por favor, escolha uma opção válida."
                ;;
        esac
        read -p "Pressione Enter para continuar..."
    done
}

# Chama o menu de logs se o script for executado diretamente
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    menu_logs
fi


