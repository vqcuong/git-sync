FROM alpine

LABEL maintainer=vqcuong96@gmail.com

COPY git-clone.sh /git-clone.sh
COPY git-sync.sh /git-sync.sh
COPY entrypoint.sh /entrypoint.sh

RUN apk --update add git less openssh \
    && rm -rf /var/lib/apt/lists/* && rm /var/cache/apk/* \
    && chmod +x /git-clone.sh /git-sync.sh /entrypoint.sh

VOLUME /git
WORKDIR /git

ENTRYPOINT [ "/entrypoint.sh", "sync" ]
