FROM mysql:5.7-debian

RUN apt-get update && \
    apt-get install -y apt-utils \
                       locales && \
    rm -rf /var/lib/apt/lists/* && \
    echo "vi_VN.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen vi_VN.UTF-8
ENV LC_ALL vi_VN.UTF-8
COPY ./docker/mysql/charset.cnf /etc/mysql/conf.d/charset.cnf
