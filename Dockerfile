# Base Ruby layer
FROM ruby:2.3.0

# Add system libraries layer
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs libleptonica-dev libtesseract-dev

# Create directory for tesseract and fetch training data
RUN mkdir /usr/local/share/tessdata
RUN curl -L https://github.com/danReynolds/ruby-tesseract-ocr/raw/master/eng.traineddata > /usr/local/share/tessdata/eng.traineddata

# Set the working directory to /SupermarKit
RUN mkdir /SupermarKit
WORKDIR /SupermarKit

# Install all needed gems
ADD Gemfile /SupermarKit/Gemfile
ADD Gemfile.lock /SupermarKit/Gemfile.lock
RUN bundle install

# Copy the current directory contents into the container at /SupermarKit
ADD . /SupermarKit

# Make port 80 available to the world outside this container
EXPOSE 3000

# Define environment variable
# TEST hello

# Precompile assets for production
RUN RAILS_ENV=production bundle exec rake assets:precompile --trace

# Start server
CMD ["rails","server","-b", "0.0.0.0"]
