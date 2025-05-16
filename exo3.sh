#!/usr/bin/bash

rm -f ./fifo
mkfifo ./fifo

mdp=$(grep "^mdp=" configuration.txt | cut -d= -f2 | tr -d '[:space:]')

function interpret () {
    echo "Donne le mot de passe :"
    while read ligne_mdp; do
        if [ "$ligne_mdp" != "$mdp" ]; then
            echo "Mot de passe incorrect."
            exit
        fi
        break
    done

    echo "Bienvenue, utilisateur."
    CONN_TIME=$(date '+%Y-%m-%d %H:%M:%S')
    echo "Date de connexion : $CONN_TIME"

    while read line; do
        echo "Debug, reçu == $line ==" >&2

        if [ "$line" = "exit" ]; then 
            DISCONN_TIME=$(date '+%Y-%m-%d %H:%M:%S')
            echo "Date de déconnexion : $DISCONN_TIME"
            exit
        else
            result=$(eval "$line")
            echo "$result"
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
