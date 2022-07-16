FROM ruby:3.1.0-bullseye

RUN apt-get update && apt-get install -qq -y --no-install-recommends build-essential postgresql postgresql-contrib libpq-dev libsqlite3-dev curl imagemagick nodejs

RUN apt-get update && apt-get install -y nodejs yarn postgresql-client

RUN apt-get update && apt-get install -y \
  libxml2-dev \
  libxslt-dev \
  zlib1g-dev \
  && rm -rf /var/cache/apk/*

RUN	groupadd -r -g 1000 docker && \
		useradd -r --create-home -u 1000 -g docker docker

COPY Gemfile /jenkact/Gemfile
COPY Gemfile.lock /jenkact/Gemfile.lock

WORKDIR /jenkact

RUN chown -R docker:docker /jenkact/ && \
  chmod +w /jenkact/Gemfile.lock

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

USER root	
RUN useradd -ms /bin/bash jenkins
RUN   usermod -aG docker jenkins

USER jenkins
WORKDIR /var/lib/jenkins

USER docker

RUN gem install bundler && \
                bundle install

COPY --chown=docker:docker . /jenkact

WORKDIR /jenkact

CMD ["rails", "server", "-b", "0.0.0.0"]
