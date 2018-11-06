FROM ubuntu:16.04

RUN apt-get update && \
    apt-get install -y openjdk-8-jdk && \
    apt-get install -y ant && \
    apt-get clean;

# Fix certificate issues
RUN apt-get update && \
    apt-get install ca-certificates-java && \
    apt-get clean && \
    update-ca-certificates -f;

# Setup JAVA_HOME -- useful for docker commandline
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/
RUN export JAVA_HOME

ARG MESOS_VERSION=1.6.0

RUN touch /usr/local/bin/systemctl && chmod +x /usr/local/bin/systemctl
RUN apt-get install -y gnupg
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv DF7D54CBE56151BF
RUN echo "deb http://repos.mesosphere.io/ubuntu xenial main" > /etc/apt/sources.list.d/mesosphere.list
RUN apt-get -y update
RUN apt-get -y install --no-install-recommends "mesos=${MESOS_VERSION}*" wget libcurl3-nss
RUN apt-get -y install libatlas3-base libopenblas-base
RUN update-alternatives --set libblas.so.3 /usr/lib/openblas-base/libblas.so.3
RUN update-alternatives --set liblapack.so.3 /usr/lib/openblas-base/liblapack.so.3
RUN ln -sfT /usr/lib/libblas.so.3 /usr/lib/libblas.so
RUN ln -sfT /usr/lib/liblapack.so.3 /usr/lib/liblapack.so
RUN wget http://apache.cs.uu.nl/spark/spark-2.3.1/spark-2.3.1-bin-hadoop2.7.tgz -O /tmp/spark.tgz
RUN echo "dc3a97f3d99791d363e4f70a622b84d6e313bd852f6fdbc777d31eab44cbc112ceeaa20f7bf835492fb654f48ae57e9969f93d3b0e6ec92076d1c5e1b40b4696  /tmp/spark.tgz" | sha512sum -c -
RUN mkdir /spark
RUN tar zxf /tmp/spark.tgz -C /spark --strip-components 1
RUN apt-get remove -y wget
RUN apt-get clean -y
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN ldconfig

RUN mv /usr/lib/python2.7/site-packages/* /usr/lib/python2.7/dist-packages/ \
 && rm -rf /usr/lib/python2.7/site-packages \
 && ln -s /usr/lib/python2.7/dist-packages /usr/lib/python2.7/site-packages

ENV PATH=/spark/bin:$PATH

CMD "spark-submit.sh"
