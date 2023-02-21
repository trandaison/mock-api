FROM ruby:2.7.2

RUN apt-get update -qq && \
    apt-get install -y apt-utils \
    build-essential \
    libpq-dev \
    curl \
    default-mysql-client

ADD https://dl.yarnpkg.com/debian/pubkey.gpg /tmp/yarn-pubkey.gpg
RUN apt-key add /tmp/yarn-pubkey.gpg && rm /tmp/yarn-pubkey.gpg
RUN echo 'deb http://dl.yarnpkg.com/debian/ stable main' > /etc/apt/sources.list.d/yarn.list

# RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -
# RUN apt-get update && apt-get install -qq -y --no-install-recommends nodejs yarn

RUN mkdir /app
WORKDIR /app
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN bundle install -j4

# COPY package.json ./
# RUN yarn install

COPY . /app

EXPOSE 5000
