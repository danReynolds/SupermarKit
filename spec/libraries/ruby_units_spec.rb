describe RubyUnits do
  it 'should allow all defined unit types to be used for RubyUnits' do
    UNIT_TYPES.each do |unit|
      expect(Unit.new(unit)).not_to be_nil
    end
  end
end
