FROM ruby:3.1.0-bullseye AS prepare
COPY . .
RUN apt-get update && apt-get install -qq -y --no-install-recommends build-essential postgresql postgresql-contrib libpq-dev libsqlite3-dev curl imagemagick nodejs

RUN apt-get update && apt-get install -y nodejs yarn postgresql-client

RUN apt-get update && apt-get install -y \
  libxml2-dev \
  libxslt-dev \
  zlib1g-dev \
  && rm -rf /var/cache/apk/*
  
  
  
FROM postgres AS test

WORKDIR /jenkact
# Copy artifacts and tests

COPY --from=prepare Gemfile /jenkact
COPY --from=prepare Gemfile.lock /jenkact/Gemfile.lock
RUN bundle install

RUN	groupadd -r -g 1000 jenkins && \
		useradd -r --create-home -u 1000 -g jenkins jenkins
		
RUN chown -R jenkins:jenkins /jenkact/ && \
  chmod +w /jenkact/Gemfile.lock

USER jenkins

WORKDIR /jenkact

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]
