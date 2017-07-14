#!/bin/bash
# Ajusta permissões apartir de caminhos fornecidos por um arquivo.
# Ignora /../../../ para não serem aplicadas permissões fora do local desejado.
#
# Uso: permissiona.sh setor repositorio

SETOR=$1
REPO=$2
PASTA=/var/www/$SETOR/$REPO
CONF=$PASTA/config/perm.conf
DATA="`date +%Y%m%d`"
LOG="/var/www/codados/scripts/logs/$SETOR-$REPO-$DATA.log"

echo ""
cd $PASTA
if [[ $? == 0 ]]; then
        echo "O caminho $PASTA é valido."
        echo "Lendo arquivo de permissões: $CONF."
        if [[ -e $CONF ]]; then
                echo "Arquivo: $CONF disponível."
		echo -e "\nPressione <enter> para continuar"
		read enter;
                echo "Sanetizando caminhos e aplicando permissões."
		echo -e "\n*** `date +%Y/%m/%d` `date +%H:%M:%S` ***" >> $LOG
		echo "Aplicando permissões..." >> $LOG
        else
                echo "Arquivo: $CONF não existente."
                exit 1;
        fi
else
        echo "Nome do repositório ou setor inválido."
        echo "O caminho $PASTA não existe."
        exit 1;
fi
echo -e "\nCaminho original\t\t\t Sanetizado\t\t\t\tchmod g+w\n"
while read LINHA;
do
        CAM_T=$(echo -e "$LINHA" |
        sed 's/\.\.\///g' |     # Limpa os ../
        sed 's/\.\///g' |       # Limpa os ./
        sed 's/\/\.\.//g' |     # Limpa os /..
        sed 's/\/\/\//\//g' |   # Impares - Troca /// por /
        sed 's/\/\//\//g' |     # Pares - Troca // por /
        sed 's/\/\//\//g' |     # Pares - Troca // por / - casos de resto 1
        sed 's/^\///g' |        # Limpa os que começam com /
        sed 's/\.\./\./g')      # Troca .. por . - Arquivos nomes..txt
	echo -e "\nchmod g+w $CAM_T" >> $LOG
	chmod g+w $CAM_T 2>> $LOG
	if [[ $? == 0 ]]; then
		printf '%-40s %-40s  \e[1;32m%s\e[0m\n' $LINHA $CAM_T "OK"
		echo "Permissoes aplicadas com sucesso." >> $LOG
	else
		printf '%-40s %-40s  \e[1;31m%s\e[0m\n' $LINHA $CAM_T "Err"
	fi	
done < $CONF
echo -e "\nO log detalhado das permissoes está em:\n$LOG\n"
echo "*** Concluído ***" >> $LOG

# Limpa logs com mais de 365 dias
find /var/www/codados/scripts/logs -type f -ctime +365 -exec rm -Rf {} \;
