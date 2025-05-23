#!/usr/bin/bash

rm -f ./fifo
mkfifo ./fifo

mdp=$(grep "^mdp=" configuration.txt | cut -d= -f2 | tr -d '[:space:]')
KEY=$(grep "^cle=" configuration.txt | cut -d= -f2 | tr -d '[:space:]')

encrypt() {
    echo "$1" | tr 'a-z' "$KEY"
}

decrypt() {
    echo "$1" | tr "$KEY" 'a-z'
}

function interpret () {
    echo $(encrypt "Donne le mot de passe :")
    while read ligne_mdp; do
        if [ "$(decrypt "$ligne_mdp")" != "$mdp" ]; then
            echo $(encrypt "Mot de passe incorrect.")
            exit
        fi
        break
    done

    echo $(encrypt "Bienvenue, utilisateur.")
    CONN_TIME=$(date)
    echo $(encrypt "Date de connexion : $CONN_TIME")

    while read line; do
        DECRYPTED_LINE="$(decrypt "$line")"
        echo "Debug, reçu == $DECRYPTED_LINE ==" >&2

        if [ "$DECRYPTED_LINE" = "exit" ]; then
            DISCONN_TIME=$(date)
            echo $(encrypt "Date de déconnexion : $DISCONN_TIME")
            exit
        else
            result=$(eval "$DECRYPTED_LINE")
            echo $(encrypt "$result")
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
