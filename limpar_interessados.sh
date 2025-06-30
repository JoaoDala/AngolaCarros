#!/bin/bash

ARQUIVO="interessados.txt"

if [[ ! -f $ARQUIVO ]]; then
    dialog --title "Aviso" --msgbox "Nenhum interessado cadastrado ainda..." 6 40
    exit 0
fi

awk -v hoje=$(date +%s) '
{
    cmd = "date -d  /""$1"\" +%s"
    cmd | getline data
    close(cmd)
    if ((hoje - data) <= 15552000) print
}' "$ARQUIVO" > tmp && mv tmp "$ARQUIVO"

dialog --title "Limpeza" --msgbox "Limpeza concluída (dados >6 meses removidos)" 7 50