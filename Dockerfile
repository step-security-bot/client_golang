# This Dockerfile builds an image for a client_golang example.
#
# Use as (from the root for the client_golang repository):
#    docker build -f Dockerfile -t prometheus/golang-example .

# Run as
#    docker run -P prometheus/golang-example /random
# or
#    docker run -P prometheus/golang-example /simple

# Test as
#    curl $ip:$port/metrics

# Builder image, where we build the example.
FROM golang:1@sha256:574185e5c6b9d09873f455a7c205ea0514bfd99738c5dc7750196403a44ed4b7 AS builder
WORKDIR /go/src/github.com/prometheus/client_golang
COPY . .
WORKDIR /go/src/github.com/prometheus/client_golang/prometheus
RUN go get -d
WORKDIR /go/src/github.com/prometheus/client_golang/examples/random
RUN CGO_ENABLED=0 GOOS=linux go build -a -tags netgo -ldflags '-w'
WORKDIR /go/src/github.com/prometheus/client_golang/examples/simple
RUN CGO_ENABLED=0 GOOS=linux go build -a -tags netgo -ldflags '-w'
WORKDIR /go/src/github.com/prometheus/client_golang/examples/gocollector
RUN CGO_ENABLED=0 GOOS=linux go build -a -tags netgo -ldflags '-w'

# Final image.
FROM quay.io/prometheus/busybox:latest@sha256:dfa54ef35e438b9e71ac5549159074576b6382f95ce1a434088e05fd6b730bc4
LABEL maintainer="The Prometheus Authors <prometheus-developers@googlegroups.com>"
COPY --from=builder /go/src/github.com/prometheus/client_golang/examples/random \
    /go/src/github.com/prometheus/client_golang/examples/simple \
    /go/src/github.com/prometheus/client_golang/examples/gocollector ./
EXPOSE 8080
CMD ["echo", "Please run an example. Either /random, /simple or /gocollector"]
