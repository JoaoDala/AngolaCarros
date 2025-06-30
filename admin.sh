#!/bin/bash

cd "$(dirname "$0")"

source funcoes.sh

while true; do
    opcao=$(dialog --stdout \
            --title "MENU ADMINISTRADOR" \
            --menu "Escolha uma opção:" \
            20 60 8 \
            1 "Visualizar carros" \
            2 "Visualizar histórico de vendas" \
            3 "Visualizar Dashboard" \
            4 "Backups" \
            5 "Visualizar Logs" \
            6 "Gerenciar Usuários" \
            7 "Relatórios de Atividades" \
            8 "Configurações do Sistema" \
            9 "Gráfico de Desempenho" \
            0 "Sair da aplicação")
    
    [ $? -ne 0 ] && break  # Se o usuário pressionar Cancelar, saímos

    case $opcao in
        1)
            listar_carros
            ;;
        2)
            ver_historico_vendas
            ;;
        3)
            bash dashboard.sh
            ;;
        4)
            bash backup.sh
            ;;
        5)
            dialog --title "Últimos Logs" --textbox logs.txt 20 80
            ;;
        6)
            gerenciar_usuarios
            ;;
        7)
            gerar_relatorios
            ;;
        8)
            configurar_sistema
            ;;
        9)
            bash relatorio_grafico.sh
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