#!/bin/bash
echo "======= Procurando por arquivos e pastas ========"
#Procura por pastas
for nome in $(cat nomes.txt)
do
resposta=$(curl -s -o /dev/null -w "%{http_code}" $1/$nome/)
if [ $resposta == "200" ]
then
echo "[+] Diretorio encontrado: $nome"
fi
done

# Procura por arquivos
for nome in $(cat nomes.txt)
do
resposta2=$(curl -s -o /dev/null -w "%{http_code}" $1/$nome)
if [ $resposta2 == "200" ]
then 
echo "[!] Arquivo encontrado: $nome"
fi
done
echo "***************FIM DA BUSCA*****************"
echo " "

#Procura por servidores DNS
echo "[*] - Encontrando servidores DNS:"
host -t ns $1 | cut -d " " -f4
echo " "

#Procura por servidores de E-mail
echo "[*] - Encontrando servidores de E-mail:"
host -t mx $1 | cut -d " " -f7
echo " "

#Tenta Transferir a zona DNS
echo "[*] - Tentativa de transferencia de zona:"
for server in $(host -t ns $1 | cut -d " " -f4)
do
host -l $1 $server | grep "has address"
done
echo " "

#Busca por subdominios
echo "[*] - Encontrando subdominios:"
for subdomain in $(cat lista.txt)
do
host $subdomain.$1 | grep "has address"
done

#Salva a lista de ips do subdominio no arquivo descrito
for subdomain in $(cat lista.txt);do host $subdomain.$1 | grep "has address" | cut -d " " -f4;done > subdominios.txt
echo " "

#nmap para ver portas abertas
echo "==== Verificando portas abertas ======="
for ip in $(cat subdominios.txt)
do
nmap -v -sS -p- $ip | grep "open port" | cut -d " " -f4,5,6
done
echo " "
echo "*************** FIM DA VERIFICAÇÃO ***************"
echo " "
