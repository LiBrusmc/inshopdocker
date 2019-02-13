FROM ruby:2.4.0

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock ./
RUN gem update --system gem install bundler bundler update --bundler bundle install

COPY . .

# Проброс порта 3000 
EXPOSE 3000

# Запуск по умолчанию сервера puma
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
