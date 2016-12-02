#!/bin/bash

apt-get update
apt-get install libleptonica-dev libtesseract-dev
mkdir /usr/local/share/tessdata
curl -L https://github.com/danReynolds/ruby-tesseract-ocr/raw/master/eng.traineddata > /usr/local/share/tessdata/eng.traineddata
