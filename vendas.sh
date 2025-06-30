#!/bin/bash

cd "$(dirname "$0")"

source funcoes.sh

while true; do
    opcao=$(dialog --stdout \
            --title "MENU VENDAS" \
            --menu "Escolha uma opção:" \
            12 40 5 \
            1 "Adicionar Venda" \
            2 "Listar Vendas" \
            3 "Buscar Venda" \
            4 "Emitir comprovativo" \
            0 "Sair da aplicação")
    
    [ $? -ne 0 ] && break

    case $opcao in
        1)
            adicionar_venda
            ;;
        2)
            listar_vendas
            ;;
        3)
            buscar_venda
            ;;
        4)
            emitir_comprovativo
            ;;
        0)
            dialog --title "Sair" --msgbox "Saindo do sistema..." 6 40
            break
            ;;
        *)  
            dialog --title "Erro" --msgbox "Opção inválida!" 6 40
            ;;
    esac
done
