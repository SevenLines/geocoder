FROM postgres:9.6

RUN apt-get -y update && \
    apt-get install -y build-essential \
    curl \
    postgresql-9.6-postgis-2.3 \
    libleveldb-dev \
    libgeos++-dev \
    protobuf-compiler \
    aria2 \
    git


ARG GO_FILE=go1.9.3.linux-amd64.tar.gz

RUN aria2c -x10 -s10 https://dl.google.com/go/$GO_FILE \
    && tar xvf $GO_FILE \
    && chown -R root:root ./go \
    && mv go /usr/local

ENV GOPATH="${HOME}/go"
ENV PATH="${GOPATH}/bin:/usr/local/go/bin:${PATH}"

RUN go get github.com/omniscale/imposm3 && \
    go install github.com/omniscale/imposm3/cmd/imposm3


RUN mkdir /app && \
    chown postgres:postgres /app

COPY thesaurus_russian_osm.ths /usr/share/postgresql/9.6/tsearch_data/

USER postgres
COPY mapping.yaml /app
COPY initdb.sql /app
COPY setup_osm_database.sh /docker-entrypoint-initdb.d/
