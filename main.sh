#!/bin/bash

cd "$(dirname "$0")"

source funcoes.sh

login() {
    tentativas=0
    while [[ $tentativas -lt 3 ]]; do
        user=$(dialog --stdout \
                --title "TELA DE LOGIN" \
                --inputbox "Nome de Utilizador:" \
                8 40)
        
        pass=$(dialog --stdout \
                --title "TELA DE LOGIN" \
                --passwordbox "Senha:" \
                8 40)
        
        # Verificar se é o Admin fixo
        if [[ $user == "Admin" && $pass == "0000" ]]; then
            export user_type="Admin"
            bash admin.sh
            return
        fi
        
        # Verificar nos usuários cadastrados
        if [[ -f "usuarios.txt" ]]; then
            while IFS=: read -r username password tipo; do
                if [[ "$user" == "$username" && "$pass" == "$password" ]]; then
                    export user_type="$tipo"
                    case $tipo in
                        "Vendas") bash vendas.sh ;;
                        "Recepcao") bash recepcao.sh ;;
                        "Admin") bash admin.sh ;;  # Para caso adicionem outro admin
                        *) 
                            dialog --title "Erro" --msgbox "Tipo de usuário inválido!" 6 40
                            return
                            ;;
                    esac
                    return
                fi
            done < "usuarios.txt"
        fi
        
        dialog --title "Erro" --msgbox "Utilizador ou senha incorreta!" 6 40
        ((tentativas++))
        
        if [[ $tentativas -ge 3 ]]; then
            dialog --title "Erro" --msgbox "Número máximo de tentativas excedido. Saindo..." 6 50
            sleep 2
            clear
            exit 1
        fi
    done
}

# Verificar se é a primeira execução e criar arquivo de usuários se não existir
if [[ ! -f "usuarios.txt" ]]; then
    touch usuarios.txt
    # Adiciona apenas o admin padrão
    echo "Admin:0000:Admin" >> usuarios.txt
fi

login