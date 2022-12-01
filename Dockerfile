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

FROM debian:11 as download-samtools
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y curl tar bzip2 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
ARG SAMTOOLS_VERSION=1.16.1
RUN curl -OL https://github.com/samtools/samtools/releases/download/${SAMTOOLS_VERSION}/samtools-${SAMTOOLS_VERSION}.tar.bz2
RUN tar xjf samtools-${SAMTOOLS_VERSION}.tar.bz2

FROM debian:11 as build-samtools
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y tar build-essential libncurses-dev libcurl4-openssl-dev liblzma-dev libbz2-dev zlib1g-dev libssl-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
ARG SAMTOOLS_VERSION=1.16.1
COPY --from=download-samtools /samtools-${SAMTOOLS_VERSION} /samtools-${SAMTOOLS_VERSION}
WORKDIR /samtools-${SAMTOOLS_VERSION}
RUN ./configure
RUN make -j4
RUN make install

FROM debian:11 as download-htslib
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y curl tar bzip2 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
ARG HTSLIB_VERSION=1.16
RUN curl -OL https://github.com/samtools/htslib/releases/download/${HTSLIB_VERSION}/htslib-${HTSLIB_VERSION}.tar.bz2
RUN tar xjf htslib-${HTSLIB_VERSION}.tar.bz2

FROM debian:11 as build-htslib
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y tar build-essential libncurses-dev libcurl4-openssl-dev liblzma-dev libbz2-dev zlib1g-dev libssl-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
ARG HTSLIB_VERSION=1.16
COPY --from=download-htslib /htslib-${HTSLIB_VERSION} /htslib-${HTSLIB_VERSION}
WORKDIR /htslib-${HTSLIB_VERSION}
RUN ./configure
RUN make -j4
RUN make install

FROM debian:11-slim
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y libgomp1 unzip python3 libncurses5 libcurl4 liblzma5 bzip2 zlib1g libssl1.1 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
COPY --from=build-samtools /usr/local /usr/local
COPY --from=build-htslib /usr/local /usr/local
COPY --from=build /usr/local /usr/local
