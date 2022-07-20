FROM ruby:3.1.0
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs postgresql-client

RUN mkdir /jenkact-docker-atm
WORKDIR /jenkact-docker-atm
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
RUN bundle install -j 4

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000
 
ADD . /jenkact-docker-atm
WORKDIR /jenkact-docker-atm
