#!/bin/bash

# rede.sh - Módulo de configuração de rede para transferência de ficheiros

function configurar_rede() {
    echo "\n--- Configuração de Rede para Transferência de Ficheiros ---"
    echo "Esta função simula a configuração de rede. Em um ambiente real, você precisaria de privilégios de root e configurações específicas."
    echo "Por exemplo, para configurar um servidor FTP ou Samba, ou usar scp/rsync."
    echo "Para este projeto, vamos focar na demonstração de transferência de ficheiros via scp (assumindo que o SSH está configurado e as chaves são geridas externamente)."
    echo ""
    echo "Exemplo de uso de scp para transferir um ficheiro:"
    echo "scp /caminho/do/seu/ficheiro.txt usuario@host_remoto:/caminho/de/destino/"
    echo ""
    echo "Exemplo de uso de scp para receber um ficheiro:"
    echo "scp usuario@host_remoto:/caminho/do/ficheiro.txt /caminho/de/destino/local/"
    echo ""
    echo "Certifique-se de que o SSH está instalado e configurado corretamente nos hosts envolvidos."
}

function menu_rede() {
    while true;
    do
        clear
        echo "=============================================="
        echo "         Módulo de Configuração de Rede       "
        echo "=============================================="
        echo "1. Exibir Informações de Configuração de Rede"
        echo "0. Voltar ao Menu Principal"
        echo "=============================================="
        read -p "Escolha uma opção: " opcao_rede

        case $opcao_rede in
            1) configurar_rede ;;
            0) break ;;
            *)
                echo "Opção inválida. Por favor, escolha uma opção válida."
                ;;
        esac
        read -p "Pressione Enter para continuar..."
    done
}

# Chama o menu de rede se o script for executado diretamente
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    menu_rede
fi


