ARG final_image=alpine:latest
ARG base_image=golang:1.22
FROM ${base_image} as builder

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY ./cmd ./cmd
COPY ./internal ./internal

RUN CGO_ENABLED=0 GOOS=linux go build -a -o main ./cmd/api/main.go

FROM ${final_image} as final

RUN apk add --no-cache ca-certificates

WORKDIR /app
COPY --from=builder /app/main ./main

CMD ["./main"]
