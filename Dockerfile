# ==============================
# Сборка Go
# ==============================
FROM golang:1.22.5 as builder

WORKDIR /go/src/github.com/AliyunContainerService/image-syncer
COPY ./ ./

# публичный Go proxy, без китайских mirrors
ENV GOPROXY=https://proxy.golang.org,direct

# сборка бинарника
RUN CGO_ENABLED=0 GOOS=linux make

# ==============================
# Минималистичный runtime
# ==============================
FROM alpine:3.18  # используем стабильную версию
WORKDIR /bin/

# копируем бинарь из builder
COPY --from=builder /go/src/github.com/AliyunContainerService/image-syncer/image-syncer ./
RUN chmod +x ./image-syncer

# ставим сертификаты (Alpine сам обновит их)
RUN apk update && apk add --no-cache ca-certificates

# точка входа
ENTRYPOINT ["image-syncer"]
CMD ["--config", "/etc/image-syncer/image-syncer.json"]
