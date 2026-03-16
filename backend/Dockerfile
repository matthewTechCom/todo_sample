FROM ruby:3.3.10-slim-bookworm AS base
WORKDIR /app
RUN apt-get update -qq && apt-get install --no-install-recommends -y \
    curl ca-certificates libjemalloc2 libvips \
  && rm -rf /var/lib/apt/lists/*

FROM base AS build

RUN apt-get update -qq && apt-get install --no-install-recommends -y \
    build-essential git libpq-dev libyaml-dev pkg-config \
  && rm -rf /var/lib/apt/lists/*

COPY Gemfile Gemfile.lock ./
RUN bundle config set without 'production' \
 && bundle install \
 && rm -rf ~/.bundle/ "/usr/local/bundle"/ruby/*/cache "/usr/local/bundle"/ruby/*/bundler/gems/*/.git \
 && bundle exec bootsnap precompile --gemfile

COPY . .
EXPOSE 3000
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3000"]