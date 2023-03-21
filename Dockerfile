FROM ruby:3.2-alpine
LABEL maintainer=engineering@kodeco.com

LABEL com.github.actions.name="robles"
LABEL com.github.actions.author="Kodeco <engineering@kodeco.com>"
LABEL com.github.actions.description="Content publication for kodeco.com"
LABEL com.github.actions.color="purple"
LABEL com.github.actions.icon="book"

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
RUN git config --global --add safe.directory '*'

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
