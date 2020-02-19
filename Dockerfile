FROM debian:stretch-20200130-slim

ARG MESOS_VERSION=1.6.1

RUN apt-get -y update && apt-get -y install gnupg2

# Workaraound for https://github.com/geerlingguy/ansible-role-java/issues/64
RUN mkdir -p /usr/share/man/man1
RUN echo "deb http://repos.mesosphere.io/debian stretch main" > /etc/apt/sources.list.d/mesosphere.list \
 && apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF \
 && apt-get -y update \
 && apt-get install gnupg2 \
 && apt-get install -y openjdk-8-jdk \
 && apt-get install ca-certificates-java \
 && update-ca-certificates -f \
 && apt-get install -y ant \
 && touch /usr/local/bin/systemctl && chmod +x /usr/local/bin/systemctl \
 && apt-get install -y gnupg \
 && apt-get -y install --no-install-recommends "mesos=${MESOS_VERSION}*" wget libcurl3-nss \
 && apt-get -y install libatlas3-base libopenblas-base \
 && update-alternatives --set libblas.so.3 /usr/lib/openblas-base/libblas.so.3 \
 && update-alternatives --set liblapack.so.3 /usr/lib/openblas-base/liblapack.so.3 \
 && ln -sfT /usr/lib/libblas.so.3 /usr/lib/libblas.so \
 && ln -sfT /usr/lib/liblapack.so.3 /usr/lib/liblapack.so \
 && wget http://xenia.sote.hu/ftp/mirrors/www.apache.org/spark/spark-2.4.5/spark-2.4.5-bin-hadoop2.7.tgz -O /tmp/spark.tgz \
 && echo "2426A20C548BDFC07DF288CD1D18D1DA6B3189D0B78DEE76FA034C52A4E02895F0AD460720C526F163BA63A17EFAE4764C46A1CD8F9B04C60F9937A554DB85D2 /tmp/spark.tgz" | sha512sum -c - \
 && mkdir /spark \
 && tar zxf /tmp/spark.tgz -C /spark --strip-components 1 \
 && apt-get remove -y wget \
 && apt-get clean -y \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
 && ldconfig

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/
ENV PATH=/spark/bin:$PATH

CMD "spark-submit.sh"
