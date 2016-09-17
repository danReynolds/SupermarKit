#!/bin/bash

apt-get update
apt-get install libleptonica-dev libtesseract-dev
mkdir /usr/local/share/tessdata
curl -L https://github.com/tesseract-ocr/tessdata/raw/master/eng.traineddata > /usr/local/share/tessdata/eng.traineddata
