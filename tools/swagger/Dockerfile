FROM golang:1.13.15

ARG SWAGGER_VERSION
ENV http_proxy http://10.6.10.156:8118
ENV https_proxy http://10.6.10.156:8118
RUN curl -fsSL -o /usr/bin/swagger https://github.com/go-swagger/go-swagger/releases/download/$SWAGGER_VERSION/swagger_linux_arm64 && chmod +x /usr/bin/swagger

ENTRYPOINT ["/usr/bin/swagger"]
CMD ["--help"]
