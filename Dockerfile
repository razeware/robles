FROM ruby:2.7-slim
LABEL maintainer=engineering@razeware.com

ENV BUILD_PACKAGES="build-essential" \
    DEV_PACKAGES="" \
    RUNTIME_PACKAGES="tzdata git rsyslog imagemagick" \
    LANG="C.UTF-8"

# SYSLOG TO STDOUT
RUN \
  touch /var/log/syslog && \
  ln -sf /proc/1/fd/1 /var/log/syslog

# Hack a (potential) problem with the slim distro
#RUN for i in $(seq 1 8); do mkdir -p "/usr/share/man/man${i}"; done

RUN \
  apt-get update -qq && \
  apt-get install -y $BUILD_PACKAGES && \
  apt-get install -y $DEV_PACKAGES $RUNTIME_PACKAGES

# Configure the main working directory. This is the base
# directory used in any further RUN, COPY, and ENTRYPOINT
# commands.
RUN mkdir -p /app/robles
WORKDIR /app/robles

# Copy the Gemfile as well as the Gemfile.lock and install
# the RubyGems. This is a separate step so the dependencies
# will be cached unless changes to one of those two files
# are made.
COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs 20 --retry 5

# Copy the main application.
COPY . ./

# Default command
CMD ['bin/robles help']
