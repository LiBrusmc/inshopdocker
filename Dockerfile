#FROM ruby:2.4.0

# throw errors if Gemfile has been modified since Gemfile.lock
#RUN bundle config --global frozen 1

#WORKDIR /var/www/inshop

#COPY Gemfile Gemfile.lock ./
#RUN bundle install

#COPY . .

# Проброс порта 3000 
#EXPOSE 3000

# Запуск по умолчанию сервера puma
#CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]


# Use the barebones version of Ruby 2.4.0.
FROM ruby:2.4.0

# Optionally set a maintainer name to let people know who made this image.
MAINTAINER LiBrusmc <librusmc@gmail.com>

# Install dependencies:
# - build-essential: To ensure certain gems can be compiled
# - nodejs: Compile assets
# - libpq-dev: Communicate with postgres through the postgres gem
# - postgresql-client-9.4: In case you want to talk directly to postgres

# see update.sh for why all "apt-get install"s have to stay as one long line
RUN apt-get update && apt-get install -y nodejs --no-install-recommends && rm -rf /var/lib/apt/lists/*

# see http://guides.rubyonrails.org/command_line.html#rails-dbconsole
RUN apt-get update && apt-get install -qq -y \
build-essential \
libpq-dev \
postgresql-client \
--fix-missing \
--no-install-recommends apt-utils && rm -rf /var/lib/apt/lists/*

ENV RAILS_VERSION 5.2.2

RUN gem install rails --version "$RAILS_VERSION"

# Set an environment variable to store where the app is installed to inside
# of the Docker image.
ENV INSTALL_PATH /var/www/inshop
RUN mkdir -p $INSTALL_PATH

# This sets the context of where commands will be ran in and is documented
# on Docker's website extensively.
WORKDIR $INSTALL_PATH

# Ensure gems are cached and only get updated when they change. This will
# drastically increase build times when your gems do not change.
#COPY Gemfile Gemfile
#COPY Gemfile* ./$INSTALL_PATH
#COPY ./Gemfile $INSTALL_PATH/Gemfile
#COPY ./Gemfile.lock $INSTALL_PATH/Gemfile.lock
COPY Gemfile Gemfile.lock ./

RUN bundle install

# Copy in the application code from your work station at the current directory
# over to the working directory.
COPY . .

# Provide dummy data to Rails so it can pre-compile assets.
#RUN bundle exec rake RAILS_ENV=production \
#DATABASE_URL=postgresql://user:pass@127.0.0.1/dbname \
#SECRET_TOKEN=pickasecuretoken assets:precompile

# Expose a volume so that nginx will be able to read in assets in production.
VOLUME ["$INSTALL_PATH/public"]

# The default command that gets ran will be to start the Unicorn server.
CMD bundle exec puma -c config/puma.rb
