#!/bin/bash

ARQUIVO_CARROS="carros.txt"
CLIENTE_FILE="clientes.txt"

pausar () {
    read -p "Pressione ENTER para continuar..." -n 1
}

visualizar_carros() {
    clear
    echo "===CARROS DISPONÍVEIS==="
    if [[ -f $ARQUIVO_CARROS ]]; then
        cat "$ARQUIVO_CARROS"
    else
        echo "Nenhum carro registrado ainda!!"
    fi
}

vender_carro() {
    verficar_permissao_venda || return
    visualizar_carros
    echo ""
    read -p "Digite o nome do carro: " carro
    if grep -q "$carro" "$ARQUIVO_CARROS"; then
        sed -i "/$carro/d" "$ARQUIVO_CARROS"
        echo "Carro '$carro' vendido com sucesso!!"
        data=$(date "+%Y-%m-%d %H:%M:%S")
        echo "$data - $user vendeu o carro: $carro" >> historico_vendas.txt
    else
        echo "Carro não encontrado."
    fi
}

verficar_permissao_venda() {
    if [[ $user != "Admin" && $user != "Vendas" ]]; then
        echo "Sem permissão para vender carros!"
        pausar
        return 1
    fi
    return 0
}
logar() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $user - $1" >>logs.txt
}

adicionar_cliente() {
    exec 3>&1
    valores=$(dialog --stdout --title "Novo Cliente" \
        --form "Preencha os dados:" \
        12 60 0 \
        "Nome:" 1 1 "" 1 10 30 0 \
        "ID:" 2 1 "" 2 10 20 0 \
        "Telefone:" 3 1 "" 3 10 15 0)
    
    [ $? -ne 0 ] && return
    
    nome=$(echo "$valores" | sed -n 1p)
    cliente_id=$(echo "$valores" | sed -n 2p)
    telefone=$(echo "$valores" | sed -n 3p)

    echo "$nome:$cliente_id:$telefone" >> "$CLIENTE_FILE"
    dialog --title "Sucesso" --msgbox "Cliente adicionado com sucesso!" 6 40
    logar "Recepção adicionou cliente: $nome"
}

listar_cliente() {
    if [[ ! -f "$CLIENTE_FILE" ]]; then
        dialog --title "Clientes Cadastrados" --msgbox "Nenhum cliente cadastrado ainda!" 6 40
        return
    fi

    temp_output=$(mktemp)

    echo " Nº | Nome                 | ID    | Telefone" > "$temp_output"
    echo "----+----------------------+-------+----------------" >> "$temp_output"

    counter=1
    while IFS=: read -r nome id telefone; do
        printf " %2d | %-20s | %-5s | %s\n" \
               "$counter" "$nome" "$id" "$telefone" >> "$temp_output"
        ((counter++))
    done < "$CLIENTE_FILE"

    dialog --title "LISTA DE CLIENTES" \
           --textbox "$temp_output" 20 80

    rm "$temp_output"
}


adicionar_carro() {
    clear
    dialog --title "NOVO CARRO" --msgbox "Vamos adicionar um novo carro." 6 40

    # Solicita as informações do carro usando o dialog
    marca=$(dialog --inputbox "Digite a marca do carro:" 8 40 3>&1 1>&2 2>&3)
    modelo=$(dialog --inputbox "Digite o modelo do carro:" 8 40 3>&1 1>&2 2>&3)
    preco=$(dialog --inputbox "Digite o preço do carro:" 8 40 3>&1 1>&2 2>&3)

    # Verifica se alguma das informações foi deixada em branco
    if [[ -z "$marca" || -z "$modelo" || -z "$preco" ]]; then
        dialog --title "Erro" --msgbox "Por favor, preencha todos os campos!" 6 40
        return
    fi

    # Adiciona o carro ao arquivo
    echo "$marca:$modelo:$preco:Disponível" >> "$ARQUIVO_CARROS"

    # Exibe mensagem de sucesso
    dialog --title "Sucesso" --msgbox "Carro adicionado com sucesso!" 6 40

    # Loga a ação
    logar "Recepção adicionou carro: $marca $modelo"
}
listar_carros() {
    if [[ ! -f "$ARQUIVO_CARROS" ]]; then
        dialog --title "Carros Cadastrados" --msgbox "Nenhum carro cadastrado ainda!" 6 40
        return
    fi

    temp_output=$(mktemp)

    echo " Nº | Marca      | Modelo          | Preço         | Status" > "$temp_output"
    echo "----+------------+-----------------+---------------+--------" >> "$temp_output"

    counter=1
    while IFS=: read -r marca modelo preco status; do
        printf " %2d | %-10s | %-15s | KZ$ %-10s | %s\n" \
               "$counter" "$marca" "$modelo" "$preco" "$status" >> "$temp_output"
        ((counter++))
    done < "$ARQUIVO_CARROS"

    dialog --title "LISTA DE CARROS" \
           --textbox "$temp_output" 20 80

    rm "$temp_output"
}


alugar_carro() {
    clear
    echo "=== ALUGUEL DE CARROS ==="
    echo "========================"
    
    # Verificar se existem carros
    if [[ ! -f "$ARQUIVO_CARROS" ]]; then
        echo "Nenhum carro cadastrado ainda!"
        pausar
        return
    fi
    
    # Listar carros disponíveis
    echo "Carros Disponíveis:"
    echo "-------------------"
    
    # Criar array de carros disponíveis
    declare -a carros_disponiveis
    counter=1
    while IFS=: read -r marca modelo preco status; do
        if [[ "$status" == "Disponível" ]]; then
            printf "%2d | %-10s | %-15s | KZ$ %-10s\n" "$counter" "$marca" "$modelo" "$preco"
            carros_disponiveis[$counter]="$marca:$modelo:$preco"
            ((counter++))
        fi
    done < "$ARQUIVO_CARROS"
    
    if [[ $counter -eq 1 ]]; then
        echo "Não há carros disponíveis no momento."
        pausar
        return
    fi
    
    echo ""
    read -p "Digite o número do carro que deseja alugar: " num_carro
    
    # Validar seleção
    if [[ $num_carro -lt 1 || $num_carro -ge $counter ]]; then
        echo "Seleção inválida!"
        pausar
        return
    fi
    
    # Obter carro selecionado
    carro_selecionado="${carros_disponiveis[$num_carro]}"
    IFS=: read -r marca modelo preco <<< "$carro_selecionado"
    
    # Coletar dados do cliente
    echo ""
    read -p "Digite o nome do cliente: " nome
    read -p "Digite o número de dias para aluguel: " dias
    
    # Calcular valor total
    valor_total=$((dias * preco))
    
    # Atualizar status do carro
    temp_file=$(mktemp)
    while IFS=: read -r m md p s; do
        if [[ "$m" == "$marca" && "$md" == "$modelo" && "$p" == "$preco" ]]; then
            echo "$m:$md:$p:Alugado" >> "$temp_file"
        else
            echo "$m:$md:$p:$s" >> "$temp_file"
        fi
    done < "$ARQUIVO_CARROS"
    
    mv "$temp_file" "$ARQUIVO_CARROS"
    
    # Registrar no histórico (cria arquivo se não existir)
    data_inicio=$(date "+%Y-%m-%d")
    data_fim=$(date -d "+$dias days" "+%Y-%m-%d")
    
    # Cria o arquivo se não existir
    if [[ ! -f "historico_alugueis.txt" ]]; then
        echo "ID_Cliente:Carro:Data_Inicio:Data_Fim:Valor_Total" > historico_alugueis.txt
    fi
    
    echo "$nome:$marca $modelo:$data_inicio:$data_fim:$valor_total" >> historico_alugueis.txt
    
    # Log da operação
    logar "Aluguel realizado: $marca $modelo para cliente $nome ($dias dias)"
    
    echo ""
    echo "Aluguel realizado com sucesso!"
    echo "Carro: $marca $modelo"
    echo "Período: $data_inicio até $data_fim"
    echo "Valor total: KZ$ $valor_total"
    pausar
}

listar_alugueis() {
    if [[ ! -f "historico_alugueis.txt" ]]; then
        dialog --title "Aluguéis" --msgbox "Nenhum aluguel registrado ainda!" 6 40
        return
    fi
    
    # Formatar a saída para exibição
    temp_output=$(mktemp)
    echo "ID Cliente | Carro | Data Início | Data Fim | Valor Total" > "$temp_output"
    echo "-------------------------------------------------------" >> "$temp_output"
    
    # Processar cada linha do histórico
    while IFS=: read -r cliente carro inicio fim valor; do
        printf "%-10s | %-15s | %-10s | %-10s | KZ$ %s\n" \
               "$cliente" "$carro" "$inicio" "$fim" "$valor" >> "$temp_output"
    done < <(tail -n +2 historico_alugueis.txt)  # Ignora o cabeçalho
    
    # Exibir em caixa de diálogo
    dialog --title "CARROS ALUGADOS" \
           --textbox "$temp_output" \
           20 80
    
    rm "$temp_output"
}
ver_historico_vendas() {
    if [[ ! -f "historico_vendas.txt" ]]; then
        dialog --title "Histórico de Vendas" --msgbox "Nenhuma venda registrada ainda!" 6 40
        return
    fi
    
    dialog --title "HISTÓRICO DE VENDAS" \
           --textbox "historico_vendas.txt" \
           20 80
}
listar_vendas() {
    if [[ ! -f "historico_vendas.txt" ]]; then
        dialog --title "Vendas" --msgbox "Nenhuma venda registrada!" 6 40
        return
    fi
    
    dialog --title "HISTÓRICO DE VENDAS" \
           --textbox "historico_vendas.txt" \
           20 80
}
buscar_venda() {
    venda_id=$(dialog --stdout \
                      --title "Buscar Venda" \
                      --inputbox "Digite o ID da venda:" \
                      8 40)
    
    if [[ -z "$venda_id" || ! -f "historico_vendas.txt" ]]; then
        dialog --title "Erro" --msgbox "Venda não encontrada!" 6 40
        return
    fi
    
    # Verifica se a venda existe
    venda=$(sed -n "${venda_id}p" historico_vendas.txt)
    if [[ -z "$venda" ]]; then
        dialog --title "Erro" --msgbox "Venda não encontrada!" 6 40
        return
    fi

    # Exibe os detalhes da venda
    IFS=':' read -r data vendedor carro <<< "$venda"
    dialog --title "Detalhes da Venda" \
           --msgbox "Data: $data\nVendedor: $vendedor\nCarro: $carro" \
           8 50
}
adicionar_venda() {
    # Exemplo de adicionar venda
    vendedor=$(dialog --stdout --title "Vendedor" --inputbox "Digite o nome do vendedor:" 8 40)
    carro=$(dialog --stdout --title "Carro" --inputbox "Digite o nome do carro vendido:" 8 40)
    
    if [[ -z "$vendedor" || -z "$carro" ]]; then
        dialog --title "Erro" --msgbox "Dados da venda incompletos!" 6 40
        return
    fi
    
    data=$(date "+%Y-%m-%d %H:%M:%S")
    echo "$data:$vendedor:$carro" >> historico_vendas.txt
    dialog --title "Sucesso" --msgbox "Venda registrada com sucesso!" 6 40
}

gerenciar_usuarios() {
    while true; do
        opcao=$(dialog --stdout \
                --title "GERENCIAR USUÁRIOS" \
                --menu "Escolha uma ação:" \
                12 50 4 \
                1 "Listar usuários" \
                2 "Adicionar usuário" \
                3 "Remover usuário" \
                0 "Voltar")
        
        [ $? -ne 0 ] && break
        
        case $opcao in
            1)
                listar_usuarios
                ;;
            2)
                adicionar_usuario
                ;;
            3)
                remover_usuario
                ;;
            0)
                break
                ;;
            *)
                dialog --title "Erro" --msgbox "Opção inválida!" 6 40
                ;;
        esac
    done
}
listar_usuarios() {
    if [[ ! -f "usuarios.txt" ]]; then
        dialog --title "Usuários" --msgbox "Nenhum usuário cadastrado!" 6 40
        return
    fi
    
    temp_output=$(mktemp)
    
    echo " Nº | Usuário       | Tipo" > "$temp_output"
    echo "----+---------------+---------------" >> "$temp_output"
    
    counter=1
    while IFS=: read -r username password tipo; do
        printf " %2d | %-13s | %s\n" "$counter" "$username" "$tipo" >> "$temp_output"
        ((counter++))
    done < "usuarios.txt"
    
    dialog --title "USUÁRIOS CADASTRADOS" \
           --textbox "$temp_output" \
           15 60
    
    rm "$temp_output"
}

adicionar_usuario() {
    exec 3>&1
    valores=$(dialog --stdout --title "Novo Usuário" \
        --form "Preencha os dados:" \
        12 60 0 \
        "Nome de Usuário:" 1 1 "" 1 20 20 0 \
        "Senha:" 2 1 "" 2 20 20 0 \
        "Tipo (Vendas/Recepcao):" 3 1 "" 3 20 15 0)
    
    [ $? -ne 0 ] && return
    
    nome=$(echo "$valores" | sed -n 1p)
    senha=$(echo "$valores" | sed -n 2p)
    tipo=$(echo "$valores" | sed -n 3p)
    
        # Validar tipo
        if [[ "$tipo" != "Vendas" && "$tipo" != "Recepcao" ]]; then
            dialog --title "Erro" --msgbox "Tipo de usuário inválido! Use Vendas ou Recepcao." 8 60
            return
        fi
        
        # Verificar se usuário já existe
        if grep -q "^$nome:" "usuarios.txt"; then
            dialog --title "Erro" --msgbox "Usuário já existe!" 6 40
            return
        fi
        
        echo "$nome:$senha:$tipo" >> usuarios.txt
        dialog --title "Sucesso" --msgbox "Usuário '$nome' adicionado com sucesso!" 6 50
        logar "Administrador adicionou usuário: $nome ($tipo)"
    }

remover_usuario() {
    if [[ ! -f "usuarios.txt" ]]; then
        dialog --title "Usuários" --msgbox "Nenhum usuário cadastrado!" 6 40
        return
    fi
    
    # Não permitir remover o Admin padrão
    usuarios=$(grep -v "^Admin:" usuarios.txt | awk -F: '{print $1}' | nl)
    
    if [[ -z "$usuarios" ]]; then
        dialog --title "Usuários" --msgbox "Nenhum usuário disponível para remoção!" 6 40
        return
    fi
    
    num_usuario=$(dialog --stdout \
        --title "Remover Usuário" \
        --menu "Selecione o usuário a remover:" \
        15 50 10 \
        $usuarios)
    
    [ $? -ne 0 ] && return
    
    usuario=$(grep -v "^Admin:" usuarios.txt | sed -n "${num_usuario}p" | cut -d: -f1)
    sed -i "/^$usuario:/d" usuarios.txt
    dialog --title "Sucesso" --msgbox "Usuário '$usuario' removido com sucesso!" 6 50
    logar "Administrador removeu usuário: $usuario"
}
gerar_relatorios() {
    while true; do
        opcao=$(dialog --stdout \
                --title "RELATÓRIOS" \
                --menu "Selecione o relatório:" \
                15 50 5 \
                1 "Relatório de Vendas" \
                2 "Relatório de Aluguéis" \
                3 "Relatório de Atividades" \
                4 "Relatório de Usuários" \
                0 "Voltar")
        
        [ $? -ne 0 ] && break
        
        case $opcao in
            1)
                [[ -f "historico_vendas.txt" ]] && \
                dialog --title "Relatório de Vendas" --textbox historico_vendas.txt 20 80 || \
                dialog --title "Aviso" --msgbox "Nenhum dado de vendas disponível" 6 40
                ;;
            2)
                [[ -f "historico_alugueis.txt" ]] && \
                dialog --title "Relatório de Aluguéis" --textbox historico_alugueis.txt 20 80 || \
                dialog --title "Aviso" --msgbox "Nenhum dado de aluguéis disponível" 6 40
                ;;
            3)
                [[ -f "logs.txt" ]] && \
                dialog --title "Relatório de Atividades" --textbox logs.txt 20 80 || \
                dialog --title "Aviso" --msgbox "Nenhum log disponível" 6 40
                ;;
            4)
                listar_usuarios
                ;;
            0)
                break
                ;;
            *)
                dialog --title "Erro" --msgbox "Opção inválida!" 6 40
                ;;
        esac
    done
}
configurar_sistema() {
    dialog --title "Configurações do Sistema" \
        --msgbox "Funcionalidade em desenvolvimento.\n\nOpções futuras:\n- Limpeza automática de logs\n- Backup automático\n- Configuração de temas" \
        10 50
}

emitir_comprovativo() {
    tipo=$(dialog --stdout \
        --title "Tipo de Comprovativo" \
        --menu "Selecione o tipo de comprovativo:" \
        12 40 3 \
        1 "Comprovativo de Venda" \
        2 "Comprovativo de Aluguel" \
        3 "Comprovativo de Reserva")
    
    [ $? -ne 0 ] && return
    
    case $tipo in
        1) # Venda
            if [[ ! -f "historico_vendas.txt" ]]; then
                dialog --title "Erro" --msgbox "Nenhuma venda registrada ainda!" 6 40
                return
            fi
            
            # Criar array de vendas para o menu
            vendas=()
            while IFS=: read -r data vendedor carro; do
                vendas+=("$data" "$vendedor - $carro")
            done < <(tail -n +2 historico_vendas.txt)  # Ignora cabeçalho se existir
            
            venda_id=$(dialog --stdout \
                --title "Selecionar Venda" \
                --menu "Escolha uma venda:" \
                20 60 10 \
                "${vendas[@]}")
            
            [ -z "$venda_id" ] && return
            
            # Obter dados completos da venda selecionada
            IFS=: read -r data vendedor carro <<< "$(grep "^$venda_id:" historico_vendas.txt)"
            
            # Gerar comprovativo
            comprovativo="\n        COMPROVANTE DE VENDA\n"
            comprovativo+="======================================\n"
            comprovativo+="Data: $data\n"
            comprovativo+="Vendedor: $vendedor\n"
            comprovativo+="Carro: $carro\n"
            comprovativo+="--------------------------------------\n"
            comprovativo+="Assinatura: _________________________\n"
            comprovativo+="\n"
            comprovativo+="       Obrigado pela sua preferência!\n"
            ;;
        
        2) # Aluguel
            if [[ ! -f "historico_alugueis.txt" ]]; then
                dialog --title "Erro" --msgbox "Nenhum aluguel registrado ainda!" 6 40
                return
            fi
            
            # Criar array de aluguéis para o menu
            alugueis=()
            while IFS=: read -r cliente carro inicio fim valor; do
                alugueis+=("$cliente" "$carro (${inicio} a ${fim})")
            done < <(tail -n +2 historico_alugueis.txt)  # Ignora cabeçalho se existir
            
            aluguel_id=$(dialog --stdout \
                --title "Selecionar Aluguel" \
                --menu "Escolha um aluguel:" \
                20 60 10 \
                "${alugueis[@]}")
            
            [ -z "$aluguel_id" ] && return
            
            # Obter dados completos do aluguel selecionado
            IFS=: read -r cliente carro inicio fim valor <<< "$(grep "^$aluguel_id:" historico_alugueis.txt)"
            
            # Gerar comprovativo
            comprovativo="\n      COMPROVANTE DE ALUGUEL\n"
            comprovativo+="======================================\n"
            comprovativo+="Cliente: $cliente\n"
            comprovativo+="Carro: $carro\n"
            comprovativo+="Data de Início: $inicio\n"
            comprovativo+="Data de Término: $fim\n"
            comprovativo+="Valor Total: KZ$ $valor\n"
            comprovativo+="--------------------------------------\n"
            comprovativo+="Assinatura: _________________________\n"
            comprovativo+="\n"
            comprovativo+="        Tenha uma boa viagem!\n"
            ;;
        
        3) # Reserva
            # Implementação similar para reservas
            cliente=$(dialog --stdout --inputbox "Digite o nome do cliente:" 8 40)
            [ -z "$cliente" ] && return
            
            carro=$(dialog --stdout --inputbox "Digite o modelo do carro:" 8 40)
            [ -z "$carro" ] && return
            
            valor=$(dialog --stdout --inputbox "Digite o valor da reserva:" 8 40)
            [ -z "$valor" ] && return
            
            comprovativo="\n     COMPROVANTE DE RESERVA\n"
            comprovativo+="======================================\n"
            comprovativo+="Cliente: $cliente\n"
            comprovativo+="Carro: $carro\n"
            comprovativo+="Data de Reserva: $(date +'%d/%m/%Y')\n"
            comprovativo+="Valor da Reserva: KZ$ $valor\n"
            comprovativo+="--------------------------------------\n"
            comprovativo+="Assinatura: _________________________\n"
            comprovativo+="\n"
            comprovativo+="       Aguardamos a sua visita!\n"
            ;;
    esac
    
    # Mostrar comprovativo
    dialog --title "COMPROVATIVO" --msgbox "$comprovativo" 18 50
    
    # Perguntar se deseja imprimir/salvar
    salvar=$(dialog --stdout --yesno "Deseja salvar este comprovativo em um arquivo?" 6 40)
    if [ $? -eq 0 ]; then
        nome_arquivo="comprovativo_$(date +%Y%m%d_%H%M%S).txt"
        echo -e "$comprovativo" > "$nome_arquivo"
        dialog --title "Sucesso" --msgbox "Comprovativo salvo em: $nome_arquivo" 6 50
    fi
    
    # Registrar ação nos logs
    logar "Emissão de comprovativo (Tipo: $tipo)"
}
consultar_cliente() {
    cliente=$(dialog --stdout --inputbox "Digite o nome ou ID do cliente:" 8 50)
    [ -z "$cliente" ] && return

    temp_output=$(mktemp)
    echo "====== HISTÓRICO DO CLIENTE: $cliente ======" >> "$temp_output"
    echo "" >> "$temp_output"

    encontrou=false

    # Buscar aluguéis
    if [[ -f "historico_alugueis.txt" ]]; then
        resultados=$(grep -i "$cliente" historico_alugueis.txt)
        if [[ -n "$resultados" ]]; then
            echo ">>> ALUGUEIS:" >> "$temp_output"
            echo "$resultados" | while IFS=: read -r nome carro inicio fim valor; do
                printf "Cliente: %s\nCarro: %s\nInício: %s | Fim: %s\nValor: KZ$ %s\n\n" \
                       "$nome" "$carro" "$inicio" "$fim" "$valor" >> "$temp_output"
            done
            encontrou=true
        fi
    fi

    # Buscar vendas
    if [[ -f "historico_vendas.txt" ]]; then
        resultados=$(grep -i "$cliente" historico_vendas.txt)
        if [[ -n "$resultados" ]]; then
            echo ">>> VENDAS:" >> "$temp_output"
            echo "$resultados" | while IFS=: read -r data vendedor carro; do
                printf "Data: %s\nVendedor: %s\nCarro: %s\n\n" \
                       "$data" "$vendedor" "$carro" >> "$temp_output"
            done
            encontrou=true
        fi
    fi

    if ! $encontrou; then
        echo "Nenhum registro encontrado para o cliente '$cliente'." > "$temp_output"
    fi

    dialog --title "Histórico do Cliente" --textbox "$temp_output" 20 70
    rm "$temp_output"
}
