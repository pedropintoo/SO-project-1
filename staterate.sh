#!/bin/bash

# -------------------------------
# declare variables
# -------------------------------
newestFile="$1"
oldestFile="$2"
header="SIZE NAME"
# -------------------------------
# -------------------------------

firstLineNew=true
firstLineOld=true

while IFS= read -r lineNew
do
    if [ "$firstLineNew" = true ]; then
        firstLineNew=false
        continue
    fi

    while IFS= read -r lineOld
    do
        if [ "$firstLineOld" = true ]; then
            firstLineOld=false
            continue
        fi

        # Aqui você pode adicionar a lógica para comparar as linhas
        
        if [  ]; then
            
        fi 

    done < "$oldestFile"

    # Após comparar todas as linhas do oldestFile com a linha atual do newestFile, você pode redefinir a variável firstLineOld
    firstLineOld=true

done < "$newestFile"

