FROM ruby:2.6.3
#-alpine
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs
RUN gem install bundler -v 2.0.2

ENV APP_HOME /app/apimaxia
RUN mkdir -p $APP_HOME
WORKDIR $APP_HOME
COPY Gemfile Gemfile.lock ./
# COPY Gemfile database.yml.example ./
RUN bundle install
COPY . ./

EXPOSE ${PORT}
# EXPOSE 3004
ENTRYPOINT ["./entrypoints/docker-entrypoint.sh"]
