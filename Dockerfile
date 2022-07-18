FROM ruby:3.1.0-bullseye

RUN apt-get update && apt-get install -qq -y --no-install-recommends build-essential postgresql postgresql-contrib libpq-dev libsqlite3-dev curl imagemagick nodejs

RUN apt-get update && apt-get install -y nodejs yarn postgresql-client

RUN apt-get update && apt-get install -y \
  libxml2-dev \
  libxslt-dev \
  zlib1g-dev \
  && rm -rf /var/cache/apk/*
  
ARG USER_ID=1000
ARG GROUP_ID=1000

RUN groupadd -g ${GROUP_ID} jenkins &&\
    useradd -l -u ${USER_ID} -g jenkins jenkins 

CMD until nc -z postgres 5432; do echo "Waiting for Postgres..." && sleep 1; done \
    && psql --username=jenkins --host=postgres --list
    
EXPOSE 5432

CMD ["rails", "server", "-b", "0.0.0.0"]
