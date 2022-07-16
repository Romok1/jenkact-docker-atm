FROM ruby:3.1.0-bullseye

RUN apt-get update && apt-get install -qq -y --no-install-recommends build-essential postgresql postgresql-contrib libpq-dev libsqlite3-dev curl imagemagick nodejs

RUN apt-get update && apt-get install -y nodejs yarn postgresql-client

RUN apt-get update && apt-get install -y \
  libxml2-dev \
  libxslt-dev \
  zlib1g-dev \
  && rm -rf /var/cache/apk/*

RUN	groupadd -r -g 1000 jenkins && \
		useradd -r --create-home -u 1000 -g jenkins jenkins

COPY Gemfile /jenkact/Gemfile
COPY Gemfile.lock /jenkact/Gemfile.lock

WORKDIR /jenkact

RUN chown -R jenkins:jenkins /jenkact/ && \
  chmod +w /jenkact/Gemfile.lock

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000


USER jenkins

RUN gem install bundler && \
                bundle install

COPY --chown=jenkins:jenkins . /jenkact

WORKDIR /jenkact

WORKDIR /var/lib/jenkins

VOLUME /var/lib/jenkins

CMD ["rails", "server", "-b", "0.0.0.0"]
