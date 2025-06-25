#!/bin/bash

# main.sh - Script principal do sistema de gestão de vendas de automóveis AngolaCars

# Inclui os módulos
source ./vendas.sh
source ./clientes.sh
source ./backup.sh
source ./logs.sh
source ./rede.sh
source ./auditoria.sh

function exibir_menu() {
    clear
    echo "=============================================="
    echo "  Sistema de Gestão de Vendas de Automóveis   "
    echo "             AngolaCars                       "
    echo "=============================================="
    echo "1. Gestão de Vendas"
    echo "2. Gestão de Clientes"
    echo "3. Backup de Dados"
    echo "4. Gestão de Logs"
    echo "5. Configuração de Rede"
    echo "6. Auditoria"
    echo "0. Sair"
    echo "=============================================="
    read -p "Escolha uma opção: " opcao
}

while true;
do
    exibir_menu
    case $opcao in
        1)
            menu_vendas # Chama a função do script vendas.sh
            ;;
        2)
            menu_clientes # Chama a função do script clientes.sh
            ;;
        3)
            menu_backup # Chama a função do script backup.sh
            ;;
        4)
            menu_logs # Chama a função do script logs.sh
            ;;
        5)
            menu_rede # Chama a função do script rede.sh
            ;;
        6)
            menu_auditoria # Chama a função do script auditoria.sh
            ;;
        0)
            echo "Saindo do sistema. Até mais!"
            exit 0
            ;;
        *)
            echo "Opção inválida. Por favor, escolha uma opção válida."
            read -p "Pressione Enter para continuar..." # Pausa para o utilizador ler a mensagem
            ;;
    esac
done


