FROM ubuntu:16.04

ARG MESOS_VERSION=1.6.0

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv DF7D54CBE56151BF \
 && echo "deb http://repos.mesosphere.io/ubuntu xenial main" > /etc/apt/sources.list.d/mesosphere.list \
 && apt-get -y update \
 && apt-get install -y openjdk-8-jdk \
 && apt-get install -y ant \
 && apt-get install ca-certificates-java \
 && update-ca-certificates -f \
 && touch /usr/local/bin/systemctl && chmod +x /usr/local/bin/systemctl \
 && apt-get install -y gnupg \
 && apt-get -y install --no-install-recommends "mesos=${MESOS_VERSION}*" wget libcurl3-nss \
 && apt-get -y install libatlas3-base libopenblas-base \
 && update-alternatives --set libblas.so.3 /usr/lib/openblas-base/libblas.so.3 \
 && update-alternatives --set liblapack.so.3 /usr/lib/openblas-base/liblapack.so.3 \
 && ln -sfT /usr/lib/libblas.so.3 /usr/lib/libblas.so \
 && ln -sfT /usr/lib/liblapack.so.3 /usr/lib/liblapack.so \
 && wget http://apache.cs.uu.nl/spark/spark-2.4.1/spark-2.4.1-bin-hadoop2.7.tgz -O /tmp/spark.tgz \
 && echo "51cad7ec8a78e3855a1d6a76e097697d79ab4ac53f75d5b587f9131608c19a87632cf77bc72bbdb9282953761f0e0f8935223473680861a59bc2f99ac0cb8ec2 /tmp/spark.tgz" | sha512sum -c - \
 && mkdir /spark \
 && tar zxf /tmp/spark.tgz -C /spark --strip-components 1 \
 && apt-get remove -y wget \
 && apt-get clean -y \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
 && ldconfig

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/
ENV PATH=/spark/bin:$PATH

CMD "spark-submit.sh"
