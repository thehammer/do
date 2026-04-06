FROM ruby:3.3-slim

WORKDIR /app
COPY Gemfile .
RUN bundle install

COPY app.rb .
COPY public/ public/

EXPOSE 3000
CMD ["ruby", "app.rb"]
