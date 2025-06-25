#!/bin/bash

# vendas.sh - Módulo de gestão de vendas

ARQUIVO_VENDAS="vendas.txt"

function inicializar_arquivo_vendas() {
    if [ ! -f "$ARQUIVO_VENDAS" ]; then
        touch "$ARQUIVO_VENDAS"
        echo "Arquivo de vendas criado: $ARQUIVO_VENDAS"
    fi
}

function adicionar_venda() {
    echo "\n--- Adicionar Nova Venda ---"
    read -p "ID da Venda: " id_venda
    read -p "Data da Venda (YYYY-MM-DD): " data_venda
    read -p "ID do Cliente: " id_cliente
    read -p "Modelo do Automóvel: " modelo_automovel
    read -p "Valor da Venda: " valor_venda

    echo "$id_venda;$data_venda;$id_cliente;$modelo_automovel;$valor_venda" >> "$ARQUIVO_VENDAS"
    echo "Venda adicionada com sucesso!"
}

function listar_vendas() {
    echo "\n--- Lista de Vendas ---"
    if [ -s "$ARQUIVO_VENDAS" ]; then
        cat -n "$ARQUIVO_VENDAS"
    else
        echo "Nenhuma venda registada ainda."
    fi
}

function buscar_venda() {
    echo "\n--- Buscar Venda ---"
    read -p "Digite o ID da Venda ou Modelo do Automóvel para buscar: " termo_busca
    grep -i "$termo_busca" "$ARQUIVO_VENDAS"
    if [ $? -ne 0 ]; then
        echo "Nenhuma venda encontrada com o termo '$termo_busca'."
    fi
}

function remover_venda() {
    echo "\n--- Remover Venda ---"
    read -p "Digite o ID da Venda a ser removida: " id_remover
    
    # Cria um arquivo temporário sem a venda a ser removida
    grep -v "^$id_remover;" "$ARQUIVO_VENDAS" > "${ARQUIVO_VENDAS}.tmp"
    
    # Verifica se a venda foi realmente removida (se o tamanho do arquivo mudou)
    if [ $(wc -l < "$ARQUIVO_VENDAS") -gt $(wc -l < "${ARQUIVO_VENDAS}.tmp") ]; then
        mv "${ARQUIVO_VENDAS}.tmp" "$ARQUIVO_VENDAS"
        echo "Venda com ID '$id_remover' removida com sucesso!"
    else
        rm "${ARQUIVO_VENDAS}.tmp"
        echo "Venda com ID '$id_remover' não encontrada."
    fi
}

function menu_vendas() {
    inicializar_arquivo_vendas
    while true;
    do
        clear
        echo "=============================================="
        echo "          Módulo de Gestão de Vendas          "
        echo "=============================================="
        echo "1. Adicionar Venda"
        echo "2. Listar Vendas"
        echo "3. Buscar Venda"
        echo "4. Remover Venda"
        echo "0. Voltar ao Menu Principal"
        echo "=============================================="
        read -p "Escolha uma opção: " opcao_vendas

        case $opcao_vendas in
            1) adicionar_venda ;;
            2) listar_vendas ;;
            3) buscar_venda ;;
            4) remover_venda ;;
            0) break ;;
            *)
                echo "Opção inválida. Por favor, escolha uma opção válida."
                ;;
        esac
        read -p "Pressione Enter para continuar..."
    done
}

# Chama o menu de vendas se o script for executado diretamente
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    menu_vendas
fi


