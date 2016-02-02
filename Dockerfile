from ruby:2.2-onbuild

WORKDIR /usr/src/app/src

CMD bundle exec rake verify_pacts