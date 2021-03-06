FROM golang:1.13.15

ARG NOTARY_VERSION
ARG MIGRATE_VERSION
RUN test -n "$NOTARY_VERSION"
RUN test -n "$MIGRATE_VERSION"
ENV NOTARYPKG github.com/theupdateframework/notary
ENV MIGRATEPKG github.com/golang-migrate/migrate
ENV HTTP_PROXY http://10.6.10.156:8118
ENV HTTPS_PROXY http://10.6.10.156:8118
ENV http_proxy http://10.6.10.156:8118
ENV https_proxy http://10.6.10.156:8118
RUN go env -w GOPROXY=https://goproxy.cn,direct

RUN git clone --config http.proxy=http://10.6.10.156:8118 -b $NOTARY_VERSION https://github.com/theupdateframework/notary.git /go/src/${NOTARYPKG}
WORKDIR /go/src/${NOTARYPKG}

RUN go install -tags pkcs11 \
    -ldflags "-w -X ${NOTARYPKG}/version.GitCommit=`git rev-parse --short HEAD` -X ${NOTARYPKG}/version.NotaryVersion=`cat NOTARY_VERSION`" ${NOTARYPKG}/cmd/notary-server 

RUN go install -tags pkcs11 \
    -ldflags "-w -X ${NOTARYPKG}/version.GitCommit=`git rev-parse --short HEAD` -X ${NOTARYPKG}/version.NotaryVersion=`cat NOTARY_VERSION`" ${NOTARYPKG}/cmd/notary-signer
RUN cp -r /go/src/${NOTARYPKG}/migrations/ / 

RUN git clone --config http.proxy=http://10.6.10.156:8118 -b $MIGRATE_VERSION https://github.com/golang-migrate/migrate /go/src/${MIGRATEPKG}
WORKDIR /go/src/${MIGRATEPKG}

RUN curl -fsSL -o /usr/local/bin/dep https://github.com/golang/dep/releases/download/v0.5.4/dep-linux-arm64 && chmod +x /usr/local/bin/dep
RUN dep ensure -vendor-only

ENV DATABASES="postgres mysql redshift cassandra spanner cockroachdb clickhouse"
ENV SOURCES="file go_bindata github aws_s3 google_cloud_storage"

RUN go install -tags "$DATABASES $SOURCES" -ldflags="-X main.Version=${MIGRATE_VERSION}" ${MIGRATEPKG}/cli && mv /go/bin/cli /go/bin/migrate

