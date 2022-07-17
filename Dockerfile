FROM ruby:3.1.0-bullseye

# New

# Postgres related
RUN apt-get update && apt-get install -qq -y --no-install-recommends build-essential postgresql postgresql-contrib libpq-dev libsqlite3-dev curl imagemagick nodejs yarn postgresql-client

RUN apt-get update -q && \
    apt-get install -qy procps curl ca-certificates gnupg2 build-essential --no-install-recommends && apt-get clean
    
# RVM version to install
ARG RVM_VERSION=3.1.0
ARG BUNDLER_VERSION=2.3.16

ENV RVM_VERSION=${RVM_VERSION}
ENV BUNDLER_VERSION=${BUNDLER_VERSION}

RUN gem install bundler -v ${BUNDLER_VERSION}
RUN curl -sSL https://get.rvm.io | bash -s

ENV PATH /usr/local/rvm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

SHELL [ "/bin/bash", "-l", "-c" ]
RUN rvm requirements
RUN rvm install ${RVM_VERSION} \
  && rvm use ${RVM_VERSION} --default
CMD source /etc/profile.d/rvm.sh
CMD source ~/.rvm/scripts/rvm
RUN gem install rails --version 7.0.3 --no-ri --no-rdoc



ENV PATH $PATH:/usr/local/rvm/bin

# Existing
ENV PROJECTDIR /jenkact

WORKDIR $PROJECTDIR

COPY Gemfile ./
COPY Gemfile.lock ./


COPY . .

EXPOSE 3000

CMD ["/bin/bash", "-c, -l", "bundle", "exec", "rails" ]
