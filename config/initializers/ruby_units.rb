# Mass/volume types from
# https://github.com/olbrich/ruby-units/blob/master/lib/ruby_units/unit_definitions/standard.rb
UNIT_TYPES = %w(
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
).freeze

UNIT_TYPES.each do |unit_type|
  Unit.redefine!(unit_type) do |unit|
    unit.display_name = unit_type
  end
end
