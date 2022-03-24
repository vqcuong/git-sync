FROM alpine

LABEL maintainer=vqcuong96@gmail.com

COPY git-clone.sh /git-clone.sh
COPY git-sync.sh /git-sync.sh

RUN apk --update add git less openssh \
    && rm -rf /var/lib/apt/lists/* && rm /var/cache/apk/* \
    && chmod +x /git-clone.sh && chmod +x /git-sync.sh

VOLUME /git
WORKDIR /git

CMD ["git", "--help"]