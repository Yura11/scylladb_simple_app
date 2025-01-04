ARG base_image=golang:1.22

FROM ${base_image} as builder

WORKDIR /app

COPY .env go.mod go.sum ./

RUN go mod download

COPY ./cmd ./cmd
COPY ./internal ./internal

RUN go build -o main ./cmd/api/main.go

FROM ${base_image} as final

WORKDIR /app

COPY --from=builder /app/main /app/main

EXPOSE 10000

CMD ["/app/main"]
