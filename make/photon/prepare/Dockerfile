ARG harbor_base_image_version
ARG harbor_base_namespace
FROM ${harbor_base_namespace}/harbor-prepare-base:${harbor_base_image_version}

ENV LANG en_US.UTF-8
ENV http_proxy=http://10.6.10.156:8118
ENV https_proxy=http://10.6.10.156:8118

WORKDIR /usr/src/app

RUN mkdir -p /harbor_make

COPY make/photon/prepare/Pipfile.lock make/photon/prepare/Pipfile /usr/src/app/
RUN set -ex && pipenv install --deploy --system
COPY make/photon/prepare /usr/src/app

ENTRYPOINT [ "python3", "main.py" ]

VOLUME ["/harbor_make"]