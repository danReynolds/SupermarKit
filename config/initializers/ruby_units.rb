# Mass/volume internal unit types from
# https://github.com/olbrich/ruby-units/blob/master/lib/ruby_units/unit_definitions/standard.rb
# amended with external unit types from
# https://github.com/iancanderson/ingreedy/blob/master/lib/ingreedy/dictionaries/en.yml
INTERNAL_UNIT_TYPES = %w(
  cup
  liter
  gallon
  quart
  pint
  tablespoon
  teaspoon
  pound
  ounce
  gram
  metric-ton
  milligram
  kilogram
  milliliter
  fluid-ounce
).each do |unit_type|
  Unit.redefine!(unit_type) do |unit|
    break if unit.nil?
    unit.display_name = unit_type
  end
end

EXTERNAL_UNIT_TYPES = [
  {
    display_name: 'dash',
    aliases: %w[dash dashes],
    definition: RubyUnits::Unit.new('1/8 teaspoon')
  },
  {
    display_name: 'pinch',
    aliases: %w[pinch pinches],
    definition: RubyUnits::Unit.new('1/16 teaspoon')
  },
  {
    display_name: 'smidgen',
    aliases: %w[smidgen smidgens],
    definition: RubyUnits::Unit.new('1/32 teaspoon')
  },
  {
    display_name: 'stick',
    aliases: %w[stick sticks],
    scalar: 1,
    numerator: %w{<stick>},
    kind: :mass
  },
  {
    display_name: 'clove',
    aliases: %w[clove cloves],
    definition: RubyUnits::Unit.new('1/8 teaspoon')
  },
  {
    display_name: 'can',
    aliases: %w[can cans],
    definition: RubyUnits::Unit.new('18.6 ounces')
  },
].each do |unit_params|
  Unit.define(unit_params[:display_name]) do |unit|
    unit_params.each do |k, v|
      unit.send("#{k}=", v)
    end
  end
end

UNIT_TYPES = INTERNAL_UNIT_TYPES + EXTERNAL_UNIT_TYPES.map { |type| type[:display_name] }
UNIT_TYPES.freeze
