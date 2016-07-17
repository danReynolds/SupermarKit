require 'tesseract'

input_file = ARGV[1]
cleaned_file = ARGV[2]

e = Tesseract::Engine.new {|e|
  e.language  = :eng
  e.blacklist = '|'
}

%x[ ./textcleaner -g -e normalize -f 30 -o 12 -s 2 "receipt.jpg" "receipt3.png" ]

puts e.text_for("receipt3.png").strip.split("\n")
