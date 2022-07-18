FROM ruby:3.1.0-bullseye

RUN apt-get update && apt-get install -qq -y --no-install-recommends build-essential postgresql postgresql-contrib libpq-dev libsqlite3-dev curl imagemagick nodejs

RUN apt-get update && apt-get install -y nodejs yarn postgresql-client

RUN apt-get update && apt-get install -y \
  libxml2-dev \
  libxslt-dev \
  zlib1g-dev \
  && rm -rf /var/cache/apk/*


EXPOSE 3000

WORKDIR /jenkact

RUN chmod +w /jenkact

COPY . .

CMD ["rails", "server", "-b", "0.0.0.0"]
