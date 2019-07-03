FROM ruby:2.6.3

ENV APP_HOME="/slack-bots"

RUN mkdir $APP_HOME
WORKDIR $APP_HOME

COPY Gemfile $APP_HOME/Gemfile
COPY Gemfile.lock $APP_HOME/Gemfile.lock

RUN gem install bundler
RUN bundle install

COPY . $APP_HOME

CMD ["rails", "server", "-b", "0.0.0.0"]
