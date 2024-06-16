FROM alpine:latest

RUN apk --no-cache add ca-certificates
WORKDIR /root/

COPY ./src/config/config.yml ./config.yml
COPY ./src/bin/app ./app
COPY ./.env ./.env

CMD ["./app"]