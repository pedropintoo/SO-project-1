#!/bin/bash

# String de exemplo
myString="diretorio1/diretorio2/diretorio3"

# Defina o IFS para o caractere "/"
IFS="/"

# Use a expansão de parâmetro para dividir a string
read -ra parts <<< "$myString"

# Restaure o valor original do IFS (espaço em branco)
IFS=" "

# Itere pelos elementos divididos
for part in "${parts[@]}"; do
    echo "$part"
done
