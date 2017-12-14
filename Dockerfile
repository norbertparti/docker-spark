FROM openjdk:8u151

ARG MESOS_VERSION=1.4.1

RUN touch /usr/local/bin/systemctl && chmod +x /usr/local/bin/systemctl

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv E56151BF \
 && echo "deb http://repos.mesosphere.io/debian jessie main" > /etc/apt/sources.list.d/mesosphere.list \
 && apt-get -y update \
 && apt-get -y install --no-install-recommends "mesos=${MESOS_VERSION}*" wget libcurl3-nss \
 && wget http://apache.cs.uu.nl/spark/spark-2.2.1/spark-2.2.1-bin-hadoop2.7.tgz -O /tmp/spark.tgz \
 && echo "349ee4bc95c760259c1c28aaae0d9db4146115b03d710fe57685e0d18c9f9538d0b90d9c28f4031ed45f69def5bd217a5bf77fd50f685d93eb207445787f2685 /tmp/spark.tgz" | sha512sum -c - \
 && mkdir /spark \
 && tar zxf /tmp/spark.tgz -C /spark --strip-components 1 \
 && apt-get -y install --no-install-recommends python-pip python-setuptools python-wheel \
 && apt-get remove -y wget \
 && apt-get clean -y \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN pip install PyYAML==3.12 \
 && pip install elasticsearch==5.4.0 \
 && pip install kafka==1.3.3 \
 && pip install python-dateutil==2.6.1

ENV PATH=/spark/bin:$PATH

CMD "spark-submit.sh"
