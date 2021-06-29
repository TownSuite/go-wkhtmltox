FROM ubuntu:20.04 as base

ARG DEBIAN_FRONTEND=noninteractive


## For chinese user

RUN apt-get update \
    # Install needed packagess
    && apt-get install -y --no-install-recommends xvfb wget unzip xz-utils wkhtmltopdf ca-certificates fontconfig libjpeg-turbo8 xfonts-75dpi xfonts-base xfonts-utils xfonts-encodings  \
    && mkdir -p /tmp && cd /tmp/ \
    # Install a newish wkhtmltox
    && wget -q https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.focal_amd64.deb \
    && dpkg -i wkhtmltox_0.12.5-1.focal_amd64.deb \
    && apt-get -f install -y \
    && rm wkhtmltox_0.12.5-1.focal_amd64.deb \
    # Clean
    && rm -rf /tmp/* \
    && apt-get purge -y --auto-remove unzip xz-utils wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

## For chinese user
## RUN sed -i "s/http:\/\/archive\.ubuntu\.com/http:\/\/mirrors\.aliyun\.com/g" /etc/apt/sources.list

FROM ubuntu:20.04 as tox_build

ARG DEBIAN_FRONTEND=noninteractive

# Install golang and Install go-wkhtmltox
RUN apt-get update \
	&& apt-get -y --no-install-recommends install git ca-certificates wget \
	&& apt install golang -y 
RUN go get github.com/TownSuite/go-wkhtmltox \
    && git clone https://github.com/TownSuite/go-wkhtmltox.git \
    && cd go-wkhtmltox \
    && go build \
    && mkdir -p /app \
    && cp go-wkhtmltox /app \
    && cp -r templates  /app \
    && cp app.conf /app


FROM base AS final
WORKDIR /app
COPY --from=tox_build /app .

VOLUME /app/templates

CMD ["./go-wkhtmltox", "run"]