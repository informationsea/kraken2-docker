FROM debian:11 as build
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y build-essential cmake
ARG KRAKEN2_VERSION=2.1.2
WORKDIR /work
COPY kraken2-${KRAKEN2_VERSION}.tar.gz /work
RUN tar xzf kraken2-${KRAKEN2_VERSION}.tar.gz
WORKDIR /work/kraken2-${KRAKEN2_VERSION}
RUN ./install_kraken2.sh /usr/local/bin

FROM debian:11-slim
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y libgomp1 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
COPY --from=build /usr/local /usr/local
