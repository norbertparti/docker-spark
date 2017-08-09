FROM openjdk:8

ARG MESOS_VERSION=1.2.1

RUN touch /usr/local/bin/systemctl && chmod +x /usr/local/bin/systemctl

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv E56151BF \
 && echo "deb http://repos.mesosphere.io/debian jessie main" > /etc/apt/sources.list.d/mesosphere.list \
 && apt-get -y update \
 && apt-get -y install --no-install-recommends "mesos=${MESOS_VERSION}*" wget libcurl3-nss libssl1.0.2 \
 && ln -sf /usr/lib/x86_64-linux-gnu/libcrypto.so.1.0.2 /usr/lib/x86_64-linux-gnu/libcrypto.so.1.0.0 \
 && ln -sf /usr/lib/x86_64-linux-gnu/libssl.so.1.0.0 /usr/lib/x86_64-linux-gnu/libssl.so.1.0.2 \
 && ldconfig \
 && wget http://d3kbcqa49mib13.cloudfront.net/spark-2.2.0-bin-hadoop2.7.tgz -O /tmp/spark.tgz \
 && echo "7a186a2a007b2dfd880571f7214a7d329c972510a460a8bdbef9f7f2a891019343c020f74b496a61e5aa42bc9e9a79cc99defe5cb3bf8b6f49c07e01b259bc6b /tmp/spark.tgz" | sha512sum -c - \
 && mkdir /spark \
 && tar zxf /tmp/spark.tgz -C /spark --strip-components 1 \
 && apt-get -y install --no-install-recommends python-pip python-setuptools python-wheel \
 && apt-get remove -y wget \
 && apt-get clean -y \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN pip install PyYAML==3.12 \
 && pip install elasticsearch==5.4.0 \
 && pip install kafka==1.3.3

ENV PATH=/spark/bin:$PATH

CMD "spark-submit.sh"
