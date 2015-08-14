#!/bin/bash

# read mirror.list to link /var/www/package folder
mkdir /var/www/package
sed -i '12s/DocumentRoot \/var\/www\/html/DocumentRoot \/var\/www\/package/' /etc/apache2/sites-enabled/000-default.conf
service apache2 restart

while true; do

    # parse mirror.list to share under /var/www/package path
    for i in `egrep -o '(rsync|ftp|https?)://[^ ]+' /etc/apt/mirror.list`; do
        url=${i/http:\/\//''}
        target='/var/www/package/' 

        IFS='/' read -a distName <<< "$url"
        dest=$target${distName[-1]}
        if [ ! -h $dest ]; then 
            echo "create $dest"
            ln -s /var/spool/apt-mirror/mirror/$url $dest
        fi 
    done

    printf "\n\n====== wait $TIMEOUT to execute apt-mirror command ======\n\n"
    sleep $TIMEOUT
    apt-mirror
done
