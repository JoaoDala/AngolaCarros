#!/bin/bash

cd "$(dirname "$0")"

source funcoes.sh

while true; do
    opcao=$(dialog --stdout \
            --title "MENU RECEPÇÃO" \
            --menu "Escolha uma opção:" \
            17 50 7 \
            1 "Adicionar clientes" \
            2 "Listar clientes" \
            3 "Adicionar carros" \
            4 "Listar carros" \
            5 "Alugar carros" \
            6 "Listar aluguéis" \
            7 "Emitir comprovativo" \
            8 "Consultar Histórico por Cliente" \
            0 "Sair")
    
    [ $? -ne 0 ] && break

    case $opcao in
        1)
            adicionar_cliente
            ;;
        2)
            listar_cliente
            ;;
        3)
            adicionar_carro
            ;;
        4)
            listar_carros
            ;;
        5)
            alugar_carro
            ;;
        6)
            listar_alugueis
            ;;
        7)
            emitir_comprovativo
            ;;
        8)
            consultar_cliente
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