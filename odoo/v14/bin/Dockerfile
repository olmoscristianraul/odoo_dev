ARG ODOO_VERSION
FROM odoo:${ODOO_VERSION}

USER root

# Generate locale (es_AR for right odoo es_AR language config, and C.UTF-8 for postgres and general locale data)
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update -qq && apt-get install -y locales -qq
RUN echo 'es_AR.UTF-8 UTF-8' >> /etc/locale.gen && locale-gen
RUN echo 'es_CL.UTF-8 UTF-8' >> /etc/locale.gen && locale-gen
RUN echo 'es_US.UTF-8 UTF-8' >> /etc/locale.gen && locale-gen
RUN echo 'C.UTF-8 UTF-8' >> /etc/locale.gen && locale-gen
RUN dpkg-reconfigure locales && /usr/sbin/update-locale LANG=C.UTF-8
ENV LANG C.UTF-8
ENV LANGUAGE C.UTF-8
ENV LC_ALL C.UTF-8

# Install some deps
RUN apt-get update && apt-get install -y \
    python3-pip python3-virtualenv gcc git swig \
    mercurial build-essential m2crypto

# Workers and longpolling dependencies
RUN apt-get install -y python3-gevent

## Install pip dependencies for adhoc used odoo repositories
# 
# used by many pip packages
RUN apt-get install -y python3-dev freetds-dev

# odoo-extra
RUN apt-get install -y python3-matplotlib font-manager python3-setuptools


# odoo argentina (nuevo modulo de FE).
#RUN apt-get install -y libffi-dev libssl-dev python3-m2crypto python3-httplib2 mercurial
RUN apt-get install -y libffi-dev libssl-dev python3-httplib2 mercurial


# NECESARIOS PARA SIGNXML
RUN apt-get install -y libxml2-dev libxslt-dev lib32z1-dev liblz-dev

# more dependencies
RUN apt-get install -y python3-venv python3-wheel


#################################################
# Agregar dependencias arriba de esta línea

# Upgrade antes de instalar modulos
RUN python3 -m pip install --upgrade pip

# Modulos desde requeriments.txt
COPY ./requirements.txt /requirements.txt
RUN python3 -m pip install --upgrade --ignore-installed -r /requirements.txt

## Clean apt-get (copied from odoo)
RUN apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false -o APT::AutoRemove::SuggestsImportant=false
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# fix 'dh key too small' error https://stackoverflow.com/questions/38015537/python-requests-exceptions-sslerror-dh-key-too-small
RUN sed  -i "s/CipherString = DEFAULT@SECLEVEL=2/CipherString = DEFAULT@SECLEVEL=1/" /etc/ssl/openssl.cnf
RUN mkdir /usr/local/lib/python3.7/dist-packages/pyafipws/cache
RUN chmod -R 777 /usr/local/lib/python3.7/dist-packages/pyafipws/cache

USER odoo