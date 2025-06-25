#!/bin/bash

# auditoria.sh - Módulo de auditoria

ARQUIVO_VENDAS="vendas.txt"

function verificar_vendas_abaixo_valor() {
    echo "\n--- Verificação de Vendas Abaixo do Valor Definido ---"
    read -p "Digite o valor mínimo esperado para vendas: " valor_minimo

    if ! [[ "$valor_minimo" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
        echo "Erro: Valor mínimo inválido. Por favor, insira um número."
        return 1
    fi

    echo "Vendas abaixo de $valor_minimo:"
    grep -E ".*;.*;.*;.*;([0-9]+([.][0-9]+)?)$" "$ARQUIVO_VENDAS" | awk -F';' -v min="$valor_minimo" '{
        if ($5 < min) {
            print "ID Venda: " $1 ", Data: " $2 ", Cliente: " $3 ", Automóvel: " $4 ", Valor: " $5
        }
    }'

    if [ $? -ne 0 ]; then
        echo "Nenhuma venda encontrada abaixo do valor mínimo."
    fi
}

function verificar_comprovativos() {
    echo "\n--- Verificação de Comprovativos de Venda ---"
    echo "Esta função simula a verificação de comprovativos. Em um sistema real, isso envolveria a integração com um sistema de gestão documental ou base de dados."
    echo "Para este projeto, vamos assumir que a existência de uma venda no arquivo 'vendas.txt' implica a existência de um comprovativo."
    echo ""
    echo "Para resolver a situação do cliente António José, seria necessário um sistema centralizado de acesso a comprovativos, independentemente da filial de compra."
    echo "Isso poderia ser implementado com um diretório partilhado na rede ou uma base de dados central."
}

function menu_auditoria() {
    while true;
    do
        clear
        echo "=============================================="
        echo "           Módulo de Auditoria                "
        echo "=============================================="
        echo "1. Verificar Vendas Abaixo do Valor"
        echo "2. Verificar Comprovativos de Venda (Simulação)"
        echo "0. Voltar ao Menu Principal"
        echo "=============================================="
        read -p "Escolha uma opção: " opcao_auditoria

        case $opcao_auditoria in
            1) verificar_vendas_abaixo_valor ;;
            2) verificar_comprovativos ;;
            0) break ;;
            *)
                echo "Opção inválida. Por favor, escolha uma opção válida."
                ;;
        esac
        read -p "Pressione Enter para continuar..."
    done
}

# Chama o menu de auditoria se o script for executado diretamente
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    menu_auditoria
fi


