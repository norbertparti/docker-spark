FROM debian:stretch-20200130-slim as spark_downloader

ARG SPARK_VERSION=2.4.7
ARG SPARK_SUM=0F5455672045F6110B030CE343C049855B7BA86C0ECB5E39A075FF9D093C7F648DA55DED12E72FFE65D84C32DCD5418A6D764F2D6295A3F894A4286CC80EF478
RUN apt-get -y update && apt-get install -y wget
RUN wget "http://xenia.sote.hu/ftp/mirrors/www.apache.org/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop2.7.tgz" -O /tmp/spark.tgz \
 && echo "${SPARK_SUM} /tmp/spark.tgz" | sha512sum -c - \
 && mkdir /spark \
 && tar zxf /tmp/spark.tgz -C /spark --strip-components 1


FROM debian:stretch-20200130-slim as python_downloader

ARG PYTHON_VERSION=3.7.6
ARG PYTHON_SUM=c08fbee72ad5c2c95b0f4e44bf6fd72c

RUN apt-get -y update && apt-get install -y wget xz-utils
RUN  wget "https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tar.xz"  -O /python.tar.xz \
 && echo "${PYTHON_SUM} python.tar.xz" | md5sum -c - \
 && tar -xvf /python.tar.xz



FROM debian:stretch-20200130-slim

ARG MESOS_VERSION=1.6.1

COPY --from=python_downloader /Python-3.7.6 /tmp/python/
COPY --from=spark_downloader /spark /spark

RUN apt-get -y update && apt-get -y install gnupg2
# Workaraound for https://github.com/geerlingguy/ansible-role-java/issues/64
RUN mkdir -p /usr/share/man/man1
RUN echo "deb http://repos.mesosphere.io/debian stretch main" > /etc/apt/sources.list.d/mesosphere.list \
 && apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF \
 && apt-get -y update \
 && apt-get install -y openjdk-8-jdk \
 && apt-get install ca-certificates-java \
 && update-ca-certificates -f \
 && apt-get install -y ant \
 && touch /usr/local/bin/systemctl && chmod +x /usr/local/bin/systemctl \
 && apt-get -y install --no-install-recommends "mesos=${MESOS_VERSION}*" wget libcurl3-nss \
 && apt-get -y install libatlas3-base libopenblas-base \
 && apt-get -y install sqlite3 libsqlite3-dev \
 && update-alternatives --set libblas.so.3 /usr/lib/openblas-base/libblas.so.3 \
 && update-alternatives --set liblapack.so.3 /usr/lib/openblas-base/liblapack.so.3 \
 && ln -sfT /usr/lib/libblas.so.3 /usr/lib/libblas.so \
 && ln -sfT /usr/lib/liblapack.so.3 /usr/lib/liblapack.so \
 && apt install -y build-essential liblzma-dev libbz2-dev zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev \
 && cd /tmp/python \
 && ./configure --enable-optimizations \
 && ./configure --with-lto \
 && make -j 4 && make altinstall \
 && apt-get remove -y wget \
 && apt-get clean -y \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
 && ldconfig


ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/
ENV PATH=/spark/bin:$PATH

CMD "spark-submit.sh"
