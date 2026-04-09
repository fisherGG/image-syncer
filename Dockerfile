# Stage 0: Builder
FROM golang:1.22.5 as builder
WORKDIR /go/src/github.com/AliyunContainerService/image-syncer
COPY ./ ./
ENV GOPROXY=https://proxy.golang.org,direct
RUN CGO_ENABLED=0 GOOS=linux make

# Stage 1: Runtime на UBI Minimal
FROM registry.access.redhat.com/ubi8/ubi-minimal
WORKDIR /bin/
COPY --from=builder /go/src/github.com/AliyunContainerService/image-syncer/image-syncer ./
# UBI уже содержит certs, можно проверить наличие
RUN chmod +x ./image-syncer

ENTRYPOINT ["image-syncer"]
CMD ["--config", "/etc/image-syncer/image-syncer.json"]
