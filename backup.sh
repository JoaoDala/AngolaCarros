#!/bin/bash
ARQUIVO="historico_vendas.txt"
BACKUP_DIR="backups"
mkdir -p "$BACKUP_DIR"
BACKUP_ZIP="backup_$(date +%F_%H%M).zip"

if [[ -f "$ARQUIVO" ]]; then
    zip -q "$BACKUP_DIR/$BACKUP_ZIP" "$ARQUIVO"
    dialog --title "Backup" --msgbox "Backup compactado criado:\n$BACKUP_DIR/$BACKUP_ZIP" 8 60
else
    dialog --title "Erro" --msgbox "Arquivo de histórico não encontrado!" 6 40
fi