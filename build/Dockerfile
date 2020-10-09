FROM golang:1.15-alpine as builder

WORKDIR /app
COPY go.mod ./
RUN go mod download

COPY cmd ./cmd
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go install -ldflags="-w -s" ./cmd/...

FROM gcr.io/distroless/base:nonroot
COPY --from=builder \
  /go/bin/pingserver \
  /go/bin/integrationtests \
  /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/pingserver"]
