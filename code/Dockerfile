FROM golang:1.19-alpine AS build
RUN apk add --no-cache git

WORKDIR /build
COPY go.mod .
COPY go.sum .
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o api .

FROM alpine:3.9
WORKDIR /app
RUN apk add ca-certificates
COPY --from=build /build/api .
CMD ["/app/api"]