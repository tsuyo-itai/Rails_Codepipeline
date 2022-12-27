FROM ruby:2.7.5

RUN mkdir /todoapp
WORKDIR /todoapp
COPY Gemfile /todoapp/Gemfile
COPY Gemfile.lock /todoapp/Gemfile.lock

# Bundlerの不具合対策(1)
RUN gem update --system && \
    bundle update --bundler && \
    bundle install && \
    apt-get update && \
    apt-get install -y tzdata && \
    curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && apt-get install -y nodejs

COPY . /todoapp

VOLUME /todoapp/public
VOLUME /todoapp/tmp

CMD ["sh", "launch.sh"]