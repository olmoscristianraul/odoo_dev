#!/bin/sh
# Start/stop/status container
#
### BEGIN INIT INFO
# Provides:          Sistema: aplicacion_uno
# Description:       Descripción de la aplicación
### END INIT INFO
#
### Variables
VERSION=v15
APP=odoo_$VERSION # container_name dentro de docker-compose.yaml
#
### Routes
PROXY_PATH=~/proxy/nginx/apps # Ubicación de la config del proxy
APP_PATH=~/odoo/$VERSION # Ubicación de la aplicación
#
DOCKER_PROXY=docker_nginx # Nombre del contenedor del proxy

cp_config() {
        if [ -e "$PROXY_PATH/$APP.conf" ]
        then
                echo "Config location replaced"
        else
                echo "Config location added"
        fi
        cp "$APP_PATH/bin/location/$APP.conf" "$PROXY_PATH/$APP.conf"
        reload_nginx
}

rm_config() {
        if [ -e "$PROXY_PATH/$APP.conf" ]
        then
                rm -f "$PROXY_PATH/$APP.conf"
                echo "Config location removed"
        else
                echo "Config location already removed"
        fi
        reload_nginx
}

reload_nginx() {
        NGINX_T=$(docker exec -it $DOCKER_PROXY sh -c 'nginx -t; exit $?')
        # Hago un Nginx -t dentro del contenedor, si devuelve test is successful, hago un reload del servicio
        if echo $NGINX_T | grep -q 'test is successful' ;
        then
                echo "Nginx OK, Recargando..."
                docker exec -it $DOCKER_PROXY nginx -s reload
        else
                echo "Hay un error en la configuración del proxy"
                echo ""
                docker exec -it $DOCKER_PROXY sh -c 'nginx -t; exit $?'
                echo ""
                echo "No se puede recargar el proxy hasta resolver el error"
        fi
}

case "$1" in
start)  echo "Starting container: $APP"
        docker-compose -f $APP_PATH/docker-compose.yaml up -d # init container
        cp_config # add config location to proxy
        ;;
stop)   echo "Stopping container: $APP"
        docker-compose -f $APP_PATH/docker-compose.yaml down
        rm_config # add config location to proxy
        ;;
restart) log_daemon_msg "Restarting container: $APP"
        $0 stop
        $0 start
        ;;
status)
        docker container inspect $APP -f "$APP status: {{.State.Status}}"
        ;;
*)      echo "Uso del script: ./script.sh {start|stop|status|restart}"
        exit 2
        ;;
esac
exit 0