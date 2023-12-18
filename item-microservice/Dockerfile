################
##### Builder
################
FROM ghcr.io/dattito/rust-alpine-mimalloc:1.73 as builder
RUN apk add protoc protobuf-dev

WORKDIR /app

COPY . .

RUN cargo build --release

################
##### Runtime
################
FROM scratch AS runtime 

COPY --from=builder /app/target/*-unknown-linux-musl/release/item-microservice /

EXPOSE 50051

LABEL org.opencontainers.image.source=https://github.com/dattito/nextit

ENTRYPOINT ["/item-microservice"]

