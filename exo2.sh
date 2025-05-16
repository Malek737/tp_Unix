#!/usr/bin/bash
REGEX_EQUATION="^[0-9*+\-\/\(\)]+$"

rm -f ./fifo
mkfifo ./fifo
function interpret () {

    echo "Bienvenue, utilisateur."
    CONN_TIME=$(date '+%Y-%m-%d %H:%M:%S')
    echo "Date de connexion : $CONN_TIME"

    while read line; do
        echo "Debug, reçu == $line ==" >&2

         if [ "$line" = "exit" ]; then 
            DISCONN_TIME=$(date '+%Y-%m-%d %H:%M:%S')
            echo "Date de déconnexion : $DISCONN_TIME"
            exit
        fi
        if [ $(echo "$line" | grep -P -q $REGEX_EQUATION; echo $?) -eq 0 ]; then
            result=$(echo "$line" | bc)
            echo "Résultat: $line = $result"
        fi
    done
}
echo "Démarrage de l'écoute..."
while true; do
    echo "En attente de connexion..."
    nc -l -s localhost -p 12345 < ./fifo | interpret > ./fifo
    echo "Connexion terminée"
done

echo "end."
