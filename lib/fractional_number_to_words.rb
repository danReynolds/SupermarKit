module FractionalNumberToWords
  FRACTIONAL_PHRASES = {
    (1/4) => 'a quarter',
    (1/2) => 'a half',
    (3/4) => 'three quarter'
  }.freeze

  def fractional_part_to_words(fraction)
    return FRACTIONAL_PHRASES[fraction] if FRACTIONAL_PHRASES[fraction]
    numerator_phrase = fraction.numerator.en.numwords
    denominator_phrase = fraction.denominator.en.ordinate.pluralize(fraction.numerator)
    return "#{numerator_phrase} #{denominator_phrase}"
  end

  def frac_numwords(number)
    fractional = Fractional.new(number).to_s(mixed_number: true).split(' ').map(&:to_r)

    if fractional.length == 2
      whole_number, fraction = fractional
      "#{whole_number.en.numwords} and #{fractional_part_to_words(fraction)}"
    elsif (whole_number = fractional.first).kind_of?(Fixnum)
      whole_number.en.numwords
    else
      fractional_part_to_words(fractional.first)
    end
  end
end
