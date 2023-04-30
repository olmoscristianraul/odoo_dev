#!/bin/bash
DATA_PATH="./conf/letsencrypt"
DOMAIN=hcsinergia.com
EMAIL=admin@hcsinergia.com
STAGING=0 # Set a 1 para testing

if [ "$DOMAIN" == "" ]; then
    echo "### Falta DOMAIN..."
    exit
fi
if [ "$EMAIL" == "" ]; then
    echo "### Falta EMAIL..."
    exit
fi

if [ -d "$DATA_PATH" ]; then
  read -p "Existe el certificado en la carpeta. Si continua, se borran y se solicitaran nuevos, continuar? (y/N) " decision
  if [ "$decision" != "Y" ] && [ "$decision" != "y" ]; then
    exit
  fi
fi

echo "### Borrando certificado para $DOMAIN ..."
docker-compose -f docker-compose-initiate.yaml run --rm --entrypoint "\
  rm -Rf /etc/letsencrypt/live/$DOMAIN && \
  rm -Rf /etc/letsencrypt/archive/$DOMAIN && \
  rm -Rf /etc/letsencrypt/renewal/$DOMAIN.conf" certbot
echo

# Activo staging mode si es necesario
#if [ $STAGING != "0" ]; then STAGING_ARG="--staging"; fi

# Fase 2: Inicio nginx y pido el certificado, luego detengo todo.
docker-compose -f ./docker-compose-initiate.yaml up -d nginx
docker-compose -f ./docker-compose-initiate.yaml up certbot
docker-compose -f ./docker-compose-initiate.yaml down

# --manual \
#docker-compose -f ./docker-compose-initiate.yaml run --rm --entrypoint "\
#  certbot certonly 
#    --reinstall \
#    --webroot \
#    --webroot-path=/var/www/certbot \
#    $STAGING_ARG \
#    --email $EMAIL \
#    -d *.$DOMAIN -d $DOMAIN \
#    --preferred-challenges dns \
#    --agree-tos \
#    --no-eff-email" certbot
#echo

#
 
# Fase 3: Descargo las configs de LetsEncrypt (Solo la primera vez, despues comentar)
#curl -L --create-dirs -o /home/hcsinergia/proxy/conf/letsencrypt/options-ssl-nginx.conf https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf
#openssl dhparam -out /home/hcsinergia/proxy/conf/letsencrypt/ssl-dhparams.pem 2048
 
# Fase 4: Configuro el crontab a ./conf/crontab (Solo la primera vez)
#crontab ./conf/crontab

# Fase 5: Inicio el proxy normal.
docker-compose -f ./docker-compose.yaml up -d