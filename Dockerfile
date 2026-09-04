FROM golang:1.26-alpine AS builder

RUN apk add --no-cache ca-certificates git

WORKDIR /build
COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 go build -ldflags="-s -w" -o /usr/bin/mautrix-wsproxy

FROM scratch

COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /usr/bin/mautrix-wsproxy /usr/bin/mautrix-wsproxy

ENV LISTEN_ADDRESS=:29331
EXPOSE 29331

CMD ["/usr/bin/mautrix-wsproxy", "-config", "env"]
