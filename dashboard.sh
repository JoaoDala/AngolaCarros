#!/bin/bash

cd "$(dirname "$0")"
source funcoes.sh

# Verificar existência de arquivos necessários
[[ ! -f "vendas.txt" ]] && touch vendas.txt
[[ ! -f "alugueis.txt" ]] && touch alugueis.txt

# Função para formatar valores monetários
formatar_moeda() {
    printf "KZ$ %'.2f" "$1"
}

exibir_dashboard() {
    # Obter estatísticas
    total_vendas=$(calcular_total_vendas)
    total_alugueis=$(calcular_total_alugueis)
    total_geral=$(echo "$total_vendas + $total_alugueis" | bc)
    
    # Formatando valores
    total_vendas_fmt=$(formatar_moeda "$total_vendas")
    total_alugueis_fmt=$(formatar_moeda "$total_alugueis")
    total_geral_fmt=$(formatar_moeda "$total_geral")

    dialog --title "DASHBOARD - RESUMO FINANCEIRO" \
           --msgbox "\
           RECEITA TOTAL: $total_geral_fmt\n\n\
           Vendas: $total_vendas_fmt\n\
           Aluguéis: $total_alugueis_fmt\n\n\
           Carros disponíveis: $(contar_carros)\n\
           Clientes cadastrados: $(wc -l < clientes.txt)" \
           15 50
}

exibir_dashboard