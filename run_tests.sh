#!/bin/bash

# Busca todos os arquivos que começam com 'asl'
mapfile -t FILES < <(ls asl*)

# Cores ANSI
RED='\033[0;31m'      # Vermelho
YELLOW='\033[1;33m'   # Amarelo
NC='\033[0m'          # Reset de cor

for file in "${FILES[@]}"; do
    first_line=$(head -n 1 "$file")

    if [[ "$first_line" != *"//INCORRECT"* ]]; then
        # Captura a saída do ../etapa3 e verifica se há erro
        output=$(../etapa3 < "$file" 2>&1)
        
        # Verifica se a saída contém "Erro"
        if echo "$output" | grep -q "Erro"; then
            echo -e "${RED}--> [ERRO] Arquivo ${YELLOW}$file${RED} causou um erro:${NC}"
            echo -e "${YELLOW}$output${NC}"
            echo "----------------------------------------"
        fi
    fi
done