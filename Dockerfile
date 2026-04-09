# Stage 0: Builder
FROM golang:1.22.5
WORKDIR /go/src/github.com/AliyunContainerService/image-syncer
COPY ./ ./
ENV GOPROXY=https://proxy.golang.org,direct
RUN CGO_ENABLED=0 GOOS=linux make

# Stage 1: Runtime
FROM alpine:3.18
WORKDIR /bin/
# используем индекс стадии 0 вместо имени builder
COPY --from=0 /go/src/github.com/AliyunContainerService/image-syncer/image-syncer ./
RUN chmod +x ./image-syncer \
    && apk update && apk add --no-cache ca-certificates

ENTRYPOINT ["image-syncer"]
CMD ["--config", "/etc/image-syncer/image-syncer.json"]
