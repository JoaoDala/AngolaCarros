#!/bin/bash

cd "$(dirname "$0")"

# Função para gerar barras
gerar_barras() {
    local qtd=$1
    local barra=""
    for ((i = 0; i < qtd; i++)); do
        barra+="#"
    done
    echo "$barra"
}

# Função para contar registros por mês
contar_por_mes() {
    local arquivo=$1
    local coluna_data=$2

    # Array de contagem
    declare -A meses
    for i in {1..12}; do
        meses[$i]=0
    done

    while IFS=: read -r linha; do
        data=$(echo "$linha" | cut -d':' -f$coluna_data | cut -d' ' -f1)
        mes=$(date -d "$data" +%m 2>/dev/null)
        [[ $mes =~ ^[0-9]+$ ]] && ((meses[10#$mes]++))
    done < <(tail -n +2 "$arquivo" 2>/dev/null)

    echo "${meses[@]}"
}

# Verifica existência
[[ ! -f historico_vendas.txt && ! -f historico_alugueis.txt ]] && \
    dialog --msgbox "Nenhum dado de vendas ou aluguéis encontrado." 6 50 && exit

# Contagem
vendas=($(contar_por_mes "historico_vendas.txt" 1))
aluguels=($(contar_por_mes "historico_alugueis.txt" 3))

# Meses
nomes_meses=(Jan Fev Mar Abr Mai Jun Jul Ago Set Out Nov Dez)

# Geração de gráfico
tempfile=$(mktemp)
{
    echo "RELATÓRIO GRÁFICO - VENDAS E ALUGUEIS POR MÊS"
    echo "==============================================="
    for i in {0..11}; do
        linha="${nomes_meses[$i]} | V:$(gerar_barras ${vendas[$i]}) (${vendas[$i]})"
        linha+=" | A:$(gerar_barras ${aluguels[$i]}) (${aluguels[$i]})"
        echo "$linha"
    done
} > "$tempfile"

dialog --title "Gráfico de Desempenho" --textbox "$tempfile" 20 90
rm "$tempfile"
