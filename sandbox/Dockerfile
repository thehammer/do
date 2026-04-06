FROM ruby:3.3-slim

WORKDIR /app
COPY Gemfile .
RUN bundle install

WORKDIR /game
COPY dont.rb .
RUN cp dont.rb dont.rb.original

WORKDIR /app
COPY server.rb .
COPY runner.rb .

EXPOSE 4567
CMD ["ruby", "server.rb"]
