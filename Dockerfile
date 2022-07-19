FROM ruby:3.1.0-alpine
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs

RUN mkdir /jenkact
WORKDIR /tmp
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
RUN bundle install -j 4
 
ADD . /jenkact
WORKDIR /jenkact
