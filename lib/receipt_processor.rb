module ReceiptProcessor
  class ReceiptProcessor
    RECEIPT_PATTERN = /((?:[A-za-z]+\s)+).*?(\d*\.\d+)/

    def initialize(path)
      @file = Kernel::open(path)
      @engine = Tesseract::Engine.new do |e|
        e.path = '/usr/local/share'
        e.language  = :en
        e.blacklist = ['|']
      end
    end

    def process
      @engine.text_for(@file.path).strip.split("\n")
        .map { |line| line.match(RECEIPT_PATTERN) }.compact.map(&:captures)
    end
  end
end
