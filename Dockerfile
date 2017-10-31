FROM ruby:2.3.0
ADD . /code
WORKDIR /code
RUN bundle install 
CMD ["ruby", "/code/api.rb"]
