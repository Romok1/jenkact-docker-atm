FROM ruby:3.1.0-bullseye

ENV PROJECTDIR /jenkact

WORKDIR $PROJECTDIR

COPY Gemfile ./
COPY Gemfile.lock ./


COPY . .

EXPOSE 3000

CMD ["/bin/bash", "-c -l"]
