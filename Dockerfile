FROM ruby:latest

ENV PROJECTDIR /jenkact

WORKDIR $PROJECTDIR

COPY Gemfile ./
COPY Gemfile.lock ./

RUN bundle install

COPY . .

EXPOSE 3000

CMD ["/bin/bash", "start"]
