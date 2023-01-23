# syntax=docker/dockerfile-upstream:experimental

FROM ubuntu:20.04 as build

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -qq && apt-get install -y \
    git \
    cmake \
    g++ \
    pkg-config \
    libssl-dev \
    curl \
    llvm \
    clang \
    && rm -rf /var/lib/apt/lists/*

ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH

RUN curl https://sh.rustup.rs -sSf | \
    sh -s -- -y --no-modify-path

VOLUME [ /near ]
WORKDIR /near
COPY . .

ARG CARGO_TARGET_DIR=/tmp/target
RUN cargo build --release
RUN ls -lah .

# Actual image
FROM ubuntu:20.04

EXPOSE 3030 24567

RUN apt-get update -qq && apt-get install -y \
    libssl-dev ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY --from=build /tmp/target/release/near-lake /usr/local/bin/

CMD ["/usr/local/bin/near-lake"]
