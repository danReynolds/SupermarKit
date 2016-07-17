module Paperclip
  class TextCleaner < Processor
    def initialize file, options = {}, attachment = nil
      super
      @format = File.extname(@file.path)
      @basename = File.basename(@file.path, @format)
    end

    def make
      src = @file
      dst = Tempfile.new([@basename,@format])

      dst.binmode

      begin
        parameters = '-respect-parenthesis \( :source -colorspace gray -type grayscale -contrast-stretch 0 \) \( -clone 0 -colorspace gray -negate -lat 15x15+5% -contrast-stretch 0 \) -compose copy_opacity -composite -fill "white" -opaque none +matte -deskew 40%  -auto-orient -sharpen 0x1 :dest'
        success = Paperclip.run('convert', parameters, :source => File.expand_path(@file.path), :dest => File.expand_path(dst.path))
      rescue PaperclipCommandLineError => e
        raise PaperclipError, "There was an error during the textclean conversion for #{@basename}" if @whiny
      end

      dst
    end
  end
end
