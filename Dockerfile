#os
FROM ubuntu

# libraries
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update
RUN apt-get -y install apt-utils
RUN apt-get -y install python3
RUN apt-get -y install python3-pip
RUN apt-get -y install apache2
RUN apt-get -y install libapache2-mod-wsgi

# dependencies of gamesever
COPY ./apache-gameServer/backend-gameServer/requirements.txt /var/www/backend-gameServer/requirements.txt
RUN pip3 install -r /var/www/backend-gameServer/requirements.txt

# setting up apache
COPY ./apache-gameServer/backend-gameServer.conf /etc/apache2/sites-available/backend-gameServer.conf

RUN a2ensite backend-gameServer
RUN a2enmod wsgi

COPY ./apache-gameServer/backend-gameServer.wsgi /var/www/backend-gameServer/backend-gameServer.wsgi
COPY ./run.py /var/www/backend-gameServer/run.py
COPY ./apache-gameServer/backend-gameServer /var/www/backend-gameServer/backend-gameServer/

RUN a2dissite 000-default.conf
RUN a2ensite backend-gameServer.conf

#link apache config to docker logs
RUN ln -sf /proc/self/fd/1 /var/log/apache2/access.log && \
    ln -sf /proc/self/fd/1 /var/log/apache2/error.log

EXPOSE 80
WORKDIR /var/www/backend-gameServer/

CMD /usr/sbin/apache2ctl start