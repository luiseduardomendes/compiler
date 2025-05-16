#!/bin/bash

SCRIPT_DIR="$(pwd)"

if [ ! -d "E3" ]; then
    echo "Erro: O diretório E3 não foi encontrado."
    exit 1
fi

ETAPA3_PATH=""
if [ -x "etapa3" ]; then
    ETAPA3_PATH="etapa3"
elif [ -x "$SCRIPT_DIR/etapa3" ]; then
    ETAPA3_PATH="$SCRIPT_DIR/etapa3"
else
    echo "Erro: O programa etapa3 não foi encontrado."
    read -p "Informe o caminho completo: " ETAPA3_PATH
    if [ ! -x "$ETAPA3_PATH" ]; then
        echo "Erro: O programa etapa3 não é executável."
        exit 1
    fi
fi

if ! command -v dot &> /dev/null; then
    echo "Erro: O comando 'dot' não está instalado."
    exit 1
fi

mkdir -p "$SCRIPT_DIR/temp_compare"
ALL_HTML="$SCRIPT_DIR/temp_compare/all_comparisons.html"
> "$ALL_HTML"

HTML_HEADER='<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Comparação de SVGs</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 0; }
        .tab { display: none; padding: 20px; }
        .tab.active { display: block; }
        .container { display: flex; flex-direction: row; }
        .svg-container { flex: 1; margin: 10px; border: 1px solid #ccc; padding: 10px; }
        h1, h2 { text-align: center; }
        .nav-buttons { text-align: center; margin: 20px; }
        button { padding: 10px 20px; margin: 0 10px; }
    </style>
</head>
<body>
    <h1 style="text-align:center;">Comparações de SVGs</h1>
    <div class="nav-buttons">
        <button onclick="prevTab()">Anterior</button>
        <button onclick="nextTab()">Próximo</button>
    </div>
'

HTML_FOOTER='
    <script>
        let currentTab = 0;
        const tabs = document.querySelectorAll(".tab");
        function showTab(index) {
            tabs[currentTab].classList.remove("active");
            currentTab = (index + tabs.length) % tabs.length;
            tabs[currentTab].classList.add("active");
        }
        function nextTab() { showTab(currentTab + 1); }
        function prevTab() { showTab(currentTab - 1); }
        // Inicia mostrando a primeira aba
        window.onload = () => { tabs[0]?.classList.add("active"); };
    </script>
</body>
</html>
'

echo "$HTML_HEADER" >> "$ALL_HTML"

cd E3 || exit 1
count=0

for file in *; do
    if [ -f "$file" ] && [[ "$file" != *.* ]]; then
        count=$((count + 1))
        BASENAME=$(basename "$file")
        
        "$SCRIPT_DIR/$ETAPA3_PATH" < "$file" > "$SCRIPT_DIR/E3/$BASENAME.dot"
        if [ -f "$SCRIPT_DIR/E3/$BASENAME.dot" ]; then
            dot -Tsvg "$SCRIPT_DIR/E3/$BASENAME.dot" > "$SCRIPT_DIR/E3/$BASENAME.svg"
        fi

        if [ -f "$SCRIPT_DIR/E3/$BASENAME.ref.dot" ]; then
            dot -Tsvg "$SCRIPT_DIR/E3/$BASENAME.ref.dot" > "$SCRIPT_DIR/E3/$BASENAME.ref.svg"
        fi

        if [ -f "$SCRIPT_DIR/E3/$BASENAME.svg" ] && [ -f "$SCRIPT_DIR/E3/$BASENAME.ref.svg" ]; then
            echo "<div class=\"tab\">" >> "$ALL_HTML"
            echo "<h2>Arquivo: $BASENAME</h2>" >> "$ALL_HTML"
            echo "<div class=\"container\">" >> "$ALL_HTML"
            echo "  <div class=\"svg-container\">" >> "$ALL_HTML"
            echo "    <h3>Saída do Programa</h3>" >> "$ALL_HTML"
            echo "    <object data=\"..\\E3\\$BASENAME.svg\" type=\"image/svg+xml\" width=\"100%\"></object>" >> "$ALL_HTML"
            echo "  </div>" >> "$ALL_HTML"
            echo "  <div class=\"svg-container\">" >> "$ALL_HTML"
            echo "    <h3>Referência</h3>" >> "$ALL_HTML"
            echo "    <object data=\"..\\E3\\$BASENAME.ref.svg\" type=\"image/svg+xml\" width=\"100%\"></object>" >> "$ALL_HTML"
            echo "  </div>" >> "$ALL_HTML"
            echo "</div>" >> "$ALL_HTML"
            echo "</div>" >> "$ALL_HTML"
        else
            echo "Arquivos SVG ausentes para $BASENAME. Pulando comparação."
        fi
    fi
done

cd "$SCRIPT_DIR" || exit

echo "$HTML_FOOTER" >> "$ALL_HTML"

if [ $count -eq 0 ]; then
    echo "Nenhum arquivo de teste encontrado."
    exit 1
else
    echo "Processamento completo. Comparações geradas em:"
    echo "$ALL_HTML"
    echo "Total de arquivos processados: $count"
fi
