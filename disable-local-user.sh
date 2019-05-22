#!/bin/bash

opciones() {
	# Esta función muestra las opciones.
	echo "Las opciones son:"
        echo "-d Borar cuentas en lugar de deshabilitarlas."
        echo "-r Eliminar el directorio de inicio asociado con la cuenta."
        echo "-a Crear una copia del directorio de inicio asociado a la cuenta."
           }

delete_user() {
	# Esta función elimina al usuario
	userdel $argumento
	if [ $? -ne 0 ]
	then
	 echo "El usuario $argumento no ha sido eliminado." >&2
	 exit 1
        fi
	echo "El usuario $argumento ha sido eliminado."
}

delete_dir() {
	# Esta función elimina el directorio del usuario.
	 rm -r /home/$argumento
         if [ $? -ne 0 ]
          then
          echo "El directorio del usuario $argumento no ha sido eliminado." >&2
          exit 1
         fi
          echo "El directorio del usuario $argumento ha sido eliminado."
}

backup_dir() {
	# Esta función crea un backup del directorio.

	dir='/home/'$argumento
	# Aseguramos que el directorio existe.
	if [ -d $dir ]
	then
	 backup_dir="/var/tmp/$(basename $dir)_$(date +%d-%m-%y)"
	 echo "Ruta del directorio del usuario $argumento se creo el backup en $backup_dir."
	 cp -r $dir $backup_dir
	else
	# Si el directorio no existe
	 echo "El directorio del usuario $(basename $dir) no existe."
	  exit 1
	fi
}

# Display the usage and exit.
# Make sure the script is being executed with superuser privileges.
id_user=$(id -u);
if [ $id_user -eq 0 ]
	then

	# Remove the options while leaving the remaining arguments.
	export argumento=$2

	# If the user doesn't supply at least one argument, give them help.
	if [ $# -lt 1 ]; then
	echo "Error: No se ha introducido una opción"
	echo "Uso del programa: $0 opción argumento"
	opciones
	exit 1
	fi
	if [ $# -lt 2 ]; then
		getent passwd $1 > /tmp/null
		if [ $? -eq 0 ]; then
			USER=$1
			uid=`id -u $USER`
			echo $uid
			if [ $uid -lt 1001 ]; then
				echo "no se puede desactivar porque es un usuario de sistema"
			else
				usermod -L $USER
			fi
		else
			echo "Error: No se ha introducido un argumento o una opción valida."
		 	echo "Uso del programa: $0 opción argumento."
		 	exit 1
		fi
	fi
	while getopts dra OPTION
	do
		# Parse the options.
		case $OPTION in
			d)
				delete_user
				;;
			r)
				delete_dir
				;;
			a)
				backup_dir
				;;
			?)
				opciones
				exit 1
				;;
		esac
	done
else
	echo 'No eres root.'
	exit 1
fi
