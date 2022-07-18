FROM ruby:3.1.0-bullseye AS prepare

RUN apt-get update && apt-get install -qq -y --no-install-recommends build-essential postgresql postgresql-contrib libpq-dev libsqlite3-dev curl imagemagick nodejs

RUN apt-get update && apt-get install -y nodejs yarn postgresql-client

RUN apt-get update && apt-get install -y \
  libxml2-dev \
  libxslt-dev \
  zlib1g-dev \
  && rm -rf /var/cache/apk/*
 
RUN	groupadd -r -g 1000 jenkins && \
		useradd -r --create-home -u 1000 -g jenkins jenkins

USER jenkins

COPY Gemfile /jenkact/Gemfile
COPY Gemfile.lock /jenkact/Gemfile.lock

RUN bundle install
  
  
  
FROM postgres AS test

COPY . .

WORKDIR /jenkact
# Copy artifacts and tests

COPY src /app
COPY --from=prepare Gemfile /jenkact/
COPY --from=prepare Gemfile.lock /jenkact/Gemfile.lock
RUN bundle exec rake db:migrate


USER jenkins

WORKDIR /jenkact

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]
