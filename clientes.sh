#!/bin/bash

# clientes.sh - Módulo de gestão de clientes

ARQUIVO_CLIENTES="clientes.txt"

function inicializar_arquivo_clientes() {
    if [ ! -f "$ARQUIVO_CLIENTES" ]; then
        touch "$ARQUIVO_CLIENTES"
        echo "Arquivo de clientes criado: $ARQUIVO_CLIENTES"
    fi
}

function adicionar_cliente() {
    echo "\n--- Adicionar Novo Cliente ---"
    read -p "ID do Cliente: " id_cliente
    read -p "Nome do Cliente: " nome_cliente
    read -p "Contacto: " contacto_cliente
    read -p "Data de Registo (YYYY-MM-DD): " data_registo

    echo "$id_cliente;$nome_cliente;$contacto_cliente;$data_registo" >> "$ARQUIVO_CLIENTES"
    echo "Cliente adicionado com sucesso!"
}

function listar_clientes() {
    echo "\n--- Lista de Clientes ---"
    if [ -s "$ARQUIVO_CLIENTES" ]; then
        cat -n "$ARQUIVO_CLIENTES"
    else
        echo "Nenhum cliente registado ainda."
    fi
}

function buscar_cliente() {
    echo "\n--- Buscar Cliente ---"
    read -p "Digite o ID ou Nome do Cliente para buscar: " termo_busca
    grep -i "$termo_busca" "$ARQUIVO_CLIENTES"
    if [ $? -ne 0 ]; then
        echo "Nenhum cliente encontrado com o termo 



'$termo_busca'."
    fi
}

function limpar_clientes_inativos() {
    echo "\n--- Limpar Clientes Inativos (mais de 6 meses) ---"
    # Assume que a data de registo está no formato YYYY-MM-DD
    # E que o 4º campo do clientes.txt é a data de registo
    
    DATA_LIMITE=$(date -d "6 months ago" +%Y-%m-%d)
    
    echo "Removendo clientes registados antes de $DATA_LIMITE..."
    
    # Cria um arquivo temporário com os clientes ativos
    # Itera sobre cada linha do arquivo de clientes
    # Extrai a data de registo (4º campo)
    # Compara a data de registo com a DATA_LIMITE
    # Se a data de registo for posterior ou igual à DATA_LIMITE, mantém a linha
    
    awk -F';' -v data_limite="$DATA_LIMITE" '{
        if ($4 >= data_limite) {
            print $0
        }
    }' "$ARQUIVO_CLIENTES" > "${ARQUIVO_CLIENTES}.tmp"
    
    if [ $(wc -l < "$ARQUIVO_CLIENTES") -gt $(wc -l < "${ARQUIVO_CLIENTES}.tmp") ]; then
        mv "${ARQUIVO_CLIENTES}.tmp" "$ARQUIVO_CLIENTES"
        echo "Limpeza de clientes inativos concluída com sucesso!"
    else
        rm "${ARQUIVO_CLIENTES}.tmp"
        echo "Nenhum cliente inativo encontrado para remover."
    fi
}

function menu_clientes() {
    inicializar_arquivo_clientes
    while true;
    do
        clear
        echo "=============================================="
        echo "          Módulo de Gestão de Clientes        "
        echo "=============================================="
        echo "1. Adicionar Cliente"
        echo "2. Listar Clientes"
        echo "3. Buscar Cliente"
        echo "4. Limpar Clientes Inativos"
        echo "0. Voltar ao Menu Principal"
        echo "=============================================="
        read -p "Escolha uma opção: " opcao_clientes

        case $opcao_clientes in
            1) adicionar_cliente ;;
            2) listar_clientes ;;
            3) buscar_cliente ;;
            4) limpar_clientes_inativos ;;
            0) break ;;
            *)
                echo "Opção inválida. Por favor, escolha uma opção válida."
                ;;
        esac
        read -p "Pressione Enter para continuar..."
    done
}

# Chama o menu de clientes se o script for executado diretamente
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    menu_clientes
fi


