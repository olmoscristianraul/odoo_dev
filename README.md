#IMPORTANTE
#Este ambiente es solo para trabajar en desarrollo y en mi caso, local

#Crear la red interna que llamaremos network
#En caso que esté creada la borro 

#listo las redes
docker network ls
#borrado
docker container prune --volumes
docker network prune

#Crear la red
docker network create docker_network

#Ingreso a los directorios v14 y 15 
#dentro de directorio odoo ejecuto

#Ingreso al directorio odoo y levanto la base de datos y su manejador gráfico 
docker-compose up -d

#IMPORTANTE 
#Si necesitas agregar módulos que que requieren instalar dependencias
#se deben hacer ingresando al contenedor luego de iniciado o bien incorporando 
#el cambio en el archivo  dockerfile
#y luego agregar el dato en el requirements.txt y correr 
#docker-compose build

#Inicio de Odoo 14 y 15.
#Ingresar a los directorios v14 v15 y ejecutar
docker-compose up -d

#Se requieres ver los contenedores iniciados puedes hacerlos con 
docker ps
#o tambien con   
docker stats

#SIEMPRE TENER EN CUENTA QUE LAS IMÁGENES Y CONTENEDORES OCUPAN ESPACIO
#Para listar las imágenes existentes puedes hacerlo con 
docker image ls

#Si deseas borrar imagenes que no necesitas
docker rmi imagen_nombre

#Si te toca trabajar offline o requieres resguardar

#Guardar una imagen 
docker save -o postgres:10.1-alpine > /opt/hcsinergia.com/postgres.tar
#o
docker save myimage:latest | gzip > myimage_latest.tar.gz
gzip postgres.tar

#para cargar la imagen en otro equipo
docker load < postgres.tar.gz

#Cambiar lineas en proxy para trabajar local
#docker-compose.yml de proxy comentar lineas de ssl

#IMPORTANTE Generar el Archivo .env en PATH/proxy
#en mi caso el nombre de mi equipo es cristian-dev pero podrías poner localhost

DOMAIN=hcsinergia.com > cristian-dev
EMAIL=admin@hcsinergia.com

#Levantar el proxy
docker-compose up -d

#con eso tengo Odoo 14 y 15 correiendo.

#Odoo15
http://cristian-dev/

#Odoo14
http://odoo14.cristian-dev/

#PGWEB
http://cristian-dev:8081/

#WDB Odoo15
http://cristian-dev:15984/

#WDB odoo14
http://odoo14.cristian-dev:14984/

#Clonar Repositorios
#Dentro de los directorios Odoo14 y 15 se encuentra un directorio llamado addons que es 
#nuestro directorio de trabajo y donde se clonan los módulos que necesitamos. 
#además existe un archivo repos.sh que es donde un script que usamos para especificar
#los repositorios a clonar. 
#Al ejecutarlo se clonarán los repositorios indicados dentro del directorio indicado 

#Estructura recomendada para especificar las líneas 
git clone https://github.com/url_nombre.git -b $ODOO_VERSION --depth $DEPTH_DEFAULT $ADDONS_PATH/nombre
#Luego de clonados los módulos, debemos especificarle la ruta a odoo y lo hacemos editando el achivo odoo.conf que se 
#encuentra dentro de v14/bin/config o v15/bin/config

#Al ingresar veremos al final del archivo lo siguiente

	addons_path = /mnt/extra-addons

#Debe quedar de esta forma luego de especificar los directorios de los módulos clonados.

       addons_path  = 	/mnt/extra-addons,
			/mnt/extra-addons/nuevo_módulo1,
			/mnt/extra-addons/nuevo_módulo2

#IMPORTANTE
#El archivo odoo.conf tiene seteada la contraseña maestra www.hcsinergia.com


#siempre agregamos una coma al finalizar cada línea menos en la última.
#IMPORTANTE
#En caso de olvidamos una coma o existe una ruta incorrecta siempre que no sea de gravedad podria verse odoo sin los estilos al iniciar

#notaras que hay otros archivos que no se utilizan, sobre todo los de ssl, son para llevarlos a un servidor y no se usa local. 

#M2CRYPTO
#Hoy 30/4/2023 existen cambios que se han realizado vinculados a la instalación de M2Crypto y lo hacemos a mano. (lo incorporaremos a esta infra)
#por el momento los pasos para instalar la libreria que se utiliza para la localización argentina son

#Como primer paso vamos a descargar m2crypto en micaso lo hago en una terminal linux
wget https://gitlab.com/m2crypto/m2crypto/-/archive/master/m2crypto-master.tar.gz

#Luego, evío el arvhivo descargado al directorio raíz de mi contenedor.
docker cp m2crypto-master.tar.gz odoo_v14:/

#Ahora ingreso a mi contenedor con usuario root
docker exec -it -u root odoo_v14 bash

#ingreso al directorio generado al descomprimir
cd m2crypto-master

#realizo el build
python3 setup.py build

#finalmente realizo la instalación
python3 setup.py install

#por último decir que para mantener mas de 1 versión estamos utilizando los carchivos odoo14.conf.template y odoo15.conf.template
#los otros archivos no se estan usando para el local al igual que letsencrypt 
