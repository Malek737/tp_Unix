#!/bin/bash

coproc NET { nc localhost 12345; }

read -p "Mot de passe : " password
read -p "Clé de chiffrement (26 lettres) : " KEY

ALPHA="abcdefghijklmnopqrstuvwxyz"

encrypt() {
	echo "$1" | tr "$ALPHA" "$KEY"
}

decrypt() {
    echo "$1" | tr "$KEY" "$ALPHA"
}

echo "$(encrypt $password)" >&"${NET[1]}"

read -u ${NET[0]} encrypted_response
echo "$(decrypt "$encrypted_response")"
read -u ${NET[0]} encrypted_response
echo "$(decrypt "$encrypted_response")"
read -u ${NET[0]} encrypted_response
echo "$(decrypt "$encrypted_response")"

while true; do
	read -p "Entrer une commande: " input
	encrypted=$(encrypt "$input")
	echo "$encrypted" >&${NET[1]}

	if ! read -r encrypted_response <&${NET[0]}; then
		echo "Déconnecté du serveur."
		break
	fi

	response=$(decrypt "$encrypted_response")
	echo "$response"

	[ "$input" = "exit" ] && break
done