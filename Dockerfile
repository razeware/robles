ARG RUBY_ENV

FROM ruby:3.2-alpine AS builder
LABEL maintainer=engineering@kodeco.com

ARG APP_ROOT=/app/robles
ARG BUILD_PACKAGES="build-base git"
ARG DEV_PACKAGES="bash imagemagick libsodium-dev"
ARG RUBY_PACKAGES="tzdata"

# SYSLOG TO STDOUT
RUN \
  touch /var/log/syslog && \
  ln -sf /proc/1/fd/1 /var/log/syslog

# install packages
RUN apk update \
    && apk upgrade \
    && apk add --update --no-cache $BUILD_PACKAGES $DEV_PACKAGES \
       $RUBY_PACKAGES

# Configure git
RUN git config --system --add safe.directory '*'

# Configure the main working directory. This is the base
# directory used in any further RUN, COPY, and ENTRYPOINT
# commands.
RUN mkdir -p $APP_ROOT
WORKDIR $APP_ROOT

# Copy the Gemfile as well as the Gemfile.lock and install
# the RubyGems. This is a separate step so the dependencies
# will be cached unless changes to one of those two files
# are made.
COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs 20 --retry 5

# Copy the main application.
COPY . ./

# Remove extra files
RUN rm -rf /usr/local/bundle/cache/*


##############################
# PACKAGE STAGE              #
##############################
FROM ruby:3.2-alpine
LABEL maintainer=engineering@kodeco.com
LABEL com.github.actions.name="robles"
LABEL com.github.actions.author="Kodeco <engineering@kodeco.com>"
LABEL com.github.actions.description="Content publication for kodeco.com"
LABEL com.github.actions.color="purple"
LABEL com.github.actions.icon="book"

ARG APP_ROOT=/app/robles
ARG RUBY_ENV=${RUBY_ENV:-production}

ENV RUBY_ENV=${RUBY_ENV}

ARG RUNTIME_PACKAGES="imagemagick git tzdata"
ARG TEST_AND_DEV_PACKAGES="bash build-base libsodium-dev"

# SYSLOG TO STDOUT
RUN \
  touch /var/log/syslog && \
  ln -sf /proc/1/fd/1 /var/log/syslog

# libsodium
COPY --from=builder /usr/lib/libsodium.so* /usr/lib/
# Copy the app from builder
COPY --from=builder $APP_ROOT $APP_ROOT
COPY --from=builder /usr/local/bundle /usr/local/bundle

# Set the working directory
WORKDIR $APP_ROOT

# For runtime
RUN apk update \
    && apk upgrade \
    && apk add --update --no-cache $RUNTIME_PACKAGES \
    && rm -rf /var/cache/apk/*

# Test and dev packages
RUN if [ "$RUBY_ENV" == "test" -o "$RUBY_ENV" == "development" ]; then \
    apk add --update --no-cache $TEST_AND_DEV_PACKAGES \
      && rm -rf /var/cache/apk/*; \
  fi
