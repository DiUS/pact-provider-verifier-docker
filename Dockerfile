FROM ruby:2-alpine

COPY Gemfile /app/
COPY Gemfile.lock /app/
RUN apk add --no-cache --virtual build-dependencies build-base && \
    gem install bundler --no-ri --no-rdoc && \
    cd /app; bundle install && \
    apk del build-dependencies build-base
COPY src/ /app/

WORKDIR /app

CMD bundle exec rake verify_pacts
