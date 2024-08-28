FROM ruby:2.3.7-alpine3.7

# Install ruby and ruby-bundler
RUN apk update && \
    apk upgrade && \
    apk add --no-cache --virtual .gem-builddeps bash build-base git libffi-dev python2 re2c \
    zlib-dev libxml2-dev libxslt-dev && \
    apk add --no-cache nodejs

RUN apk add ruby ruby-nokogiri

ADD . /usr/dashboard

WORKDIR /usr/dashboard

RUN bundle config build.nokogiri --use-system-libraries && \
    bundle install --no-cache --clean --standalone && \
    apk del --no-cache .gem-builddeps

EXPOSE 80
CMD ["dashing", "start"]
