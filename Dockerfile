# Base Ruby layer
FROM ruby:2.3.0

# Add system libraries layer
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs libleptonica-dev libtesseract-dev

# Create directory for tesseract and fetch training data
RUN mkdir /usr/local/share/tessdata
RUN curl -L https://github.com/danReynolds/ruby-tesseract-ocr/raw/master/eng.traineddata > /usr/local/share/tessdata/eng.traineddata

# Set the working directory to /app
RUN mkdir /app
WORKDIR /app

# Install all needed gems
ADD Gemfile /app/Gemfile
ADD Gemfile.lock /app/Gemfile.lock
RUN bundle install

# Copy the current directory contents into the container at /app
ADD . /app

# Start server
CMD ["rails","server","-b", "0.0.0.0"]
