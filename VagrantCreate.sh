#!/bin/sh
CURRENT_DIR=`pwd`

# Configuration vars
NAME_VM=$1
REPOSITORY_URL_VM=""
FOLDER_VAGRANT="$HOME/Vagrant VMs"
BASE_FILE_VAGRANT="VagrantfileBase"

# Defaults configuration
if [ "$NAME_VM" = "" ]; then
    NAME_VM="vm"
fi

if [ "$IP_ADDRESS_VM" = "" ]; then
    IP_ADDRESS_VM="192.168.0.99"
fi

echo "Hi, $USER!"
echo


echo "Please select vagrant box to create:"
echo "1 : Ubuntu 14 Server [ubuntu/trusty64]"
echo "2 : Ubuntu 16 Server [ubuntu/xenial64]"
echo
echo -n "Select one option: [Default: Cancel] [Enter] => "

read RESPONSE;

if [ "$RESPONSE" = "1" ]; then
        BASE_VAGRANT="ubuntu/trusty64"
elif [ "$RESPONSE" = "2" ]; then
        BASE_VAGRANT="ubuntu/xenial64"
else
  echo "This option $RESPONSE not exist, try again."
  exit
fi

echo "Please select virtual machine configuration that you want to create:"
echo "1 : ZendServer 9.0 (Apache 2.4 and PHP 7.0) alias [Bender]"
echo "2 : Apache 2.4 and PHP 7.0 alias [Homero]"
echo "3 : Apache 2.2 and PHP 5.6 alias [Popeye]"
echo "4 : Apache 2.4 and PHP 7.0 alias [All-in-one]"
echo "5 : None"
echo
echo -n "Select one option: [Default: Cancel] [Enter] => "

read RESPONSE

if [ "$RESPONSE" = "1" ]; then
    BOOTSTRAP_FILE_VAGRANT="VagrantLast.sh"
elif [ "$RESPONSE" = "2" ]; then
    BOOTSTRAP_FILE_VAGRANT="VagrantMedium.sh"
elif [ "$RESPONSE" = "3" ]; then
    BOOTSTRAP_FILE_VAGRANT="VagrantOld.sh"
elif [ "$RESPONSE" = "4" ]; then
    BOOTSTRAP_FILE_VAGRANT="VagrantUnique.sh"

    echo
    echo "This type machine need a URL repository name to download => "

    read RESPONSE

    if [ "$RESPONSE" = "" ]; then
        echo "You need repository. Cancel process."
          exit
    else
        REPOSITORY_URL_VM=$RESPONSE
    fi

    echo
    echo -n "... and password? => "

    read RESPONSE

    if [ "$RESPONSE" = "" ]; then
        echo "Password to download is neccesary. Cancel process."
          exit
    else
        REPOSITORY_PASSWORD_VM=$RESPONSE
    fi

    REPOSITORY_URL_TEMP=$REPOSITORY_URL_VM
    REPOSITORY_URL_VM=$(echo $REPOSITORY_URL_VM | sed "s|@|:$REPOSITORY_PASSWORD_VM@|g")
elif [ "$RESPONSE" = "5" ]; then
    BOOTSTRAP_FILE_VAGRANT="None"
else
  echo "This option $RESPONSE not exist, try again."
  exit
fi

echo
echo -n "Select valid IP Address for virtual machine => "

read RESPONSE

if [ "$RESPONSE" = "" ]; then
    IP_ADDRESS_VM="192.168.0.99"
else
    IP_ADDRESS_VM=$RESPONSE
fi

echo
echo "This process create this Virtual Machine:"
echo "Name:       $NAME_VM"
echo "Type:       $BOOTSTRAP_FILE_VAGRANT"
echo "IpAddress:  $IP_ADDRESS_VM"
if [ "$REPOSITORY_URL_VM" != "" ]; then
    echo "Repository: $REPOSITORY_URL_TEMP"
fi
echo -n "Are you sure? Yes/No [Default:No] [Enter] => "

read RESPONSE
echo

if [ "$RESPONSE" = "Yes" -o "$RESPONSE" = "yes" -o "$RESPONSE" = "y" ]; then
  echo "Init"
else
  echo "You cancel creation of VM."
  exit
fi
echo

echo "You are creating Virtual Machine: $NAME_VM."
PATH_VM="$FOLDER_VAGRANT/$NAME_VM"
FILE_VAGRANT_VM="$PATH_VM/Vagrantfile"
BOOTSTRAP_VAGRANT_VM="$PATH_VM/${NAME_VM}_bootstrap.sh"
echo

echo "This machine will create in $PATH_VM with distro $BASE_VAGRANT"
echo "Creating path: $PATH_VM"
mkdir -p "$PATH_VM"
echo

echo "Copying configuration file: $CURRENT_DIR/$BASE_FILE_VAGRANT to $FILE_VAGRANT_VM"
cp "$CURRENT_DIR/$BASE_FILE_VAGRANT" "$FILE_VAGRANT_VM"

if [ "$BOOTSTRAP_FILE_VAGRANT" != "None" ]; then
    echo "Copying configuration file: $CURRENT_DIR/$BOOTSTRAP_FILE_VAGRANT to $BOOTSTRAP_VAGRANT_VM"
    cp "$CURRENT_DIR/$BOOTSTRAP_FILE_VAGRANT" "$BOOTSTRAP_VAGRANT_VM"
    echo
fi

echo "Applying custumize configuration"

sed -i "s|##BASE_VAGRANT##|$BASE_VAGRANT|g" "$FILE_VAGRANT_VM"
echo "Applied configuration base [$BASE_VAGRANT]"

sed -i "s|##IP_ADDRESS_VM##|$IP_ADDRESS_VM|g" "$FILE_VAGRANT_VM"
echo "Applied configuration IP Address [$IP_ADDRESS_VM]"

sed -i "s|##NAME_VM##|$NAME_VM|g" "$FILE_VAGRANT_VM"
echo "Applied configuration name [$NAME_VM]"

if [ "$BOOTSTRAP_FILE_VAGRANT" != "None" ]; then
    sed -i "s|##BOOTSTRAP_VAGRANT_VM##|$BOOTSTRAP_VAGRANT_VM|g" "$FILE_VAGRANT_VM"
    echo "Applied configuration bootstrap [$BOOTSTRAP_VAGRANT_VM]"

    sed -i "s|##NAME_VM##|$NAME_VM|g" "$BOOTSTRAP_VAGRANT_VM"
    echo "Applied hostname in [$NAME_VM]"

    sed -i "s|##REPOSITORY_URL_VM##|$REPOSITORY_URL_VM|g" "$BOOTSTRAP_VAGRANT_VM"
    echo "Applied name repository in [$BOOTSTRAP_VAGRANT_VM]"
else
    sed -i "s|config.vm.provision :shell, path: \"##BOOTSTRAP_VAGRANT_VM##\"|# No provisioning file|g" "$FILE_VAGRANT_VM"
fi

echo

echo "Going to $PATH_VM"
cd "$PATH_VM"

echo "Instancing VM with vagrant"
echo -n "Are you sure execute vagrant up? Yes/No [Default:No] [Enter] => "

read RESPONSE
echo

if [ "$RESPONSE" = "Yes" -o "$RESPONSE" = "yes" -o "$RESPONSE" = "y" ]; then
    vagrant up --provision
    echo "Ready!, goooo!"
    vagrant ssh
else
    echo "Vagrant up no execute."
fi

echo "Process completed!"
