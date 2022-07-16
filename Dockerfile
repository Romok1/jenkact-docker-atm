FROM ruby:3.1.0-bullseye

# New
RUN apt-get update -q && \
    apt-get install -qy procps curl ca-certificates gnupg2 build-essential --no-install-recommends && apt-get clean
    
# RVM version to install
ARG RVM_VERSION=3.1.0
ENV RVM_VERSION=${RVM_VERSION}

RUN curl -sSL https://get.rvm.io | bash -s

SHELL [ "/bin/bash", "-l", "-c" ]
RUN rvm requirements
RUN rvm install ${RVM_VERSIONS} \
  && rvm use ${RVM_VERSIONS} --default
CMD source /etc/profile.d/rvm.sh \
  && source ~/.rvm/scripts/rvm
ENV PATH $PATH:/usr/local/rvm/bin

# Existing
ENV PROJECTDIR /jenkact

WORKDIR $PROJECTDIR

COPY Gemfile ./
COPY Gemfile.lock ./


COPY . .

EXPOSE 3000

CMD ["/bin/bash", "-c -l"]
