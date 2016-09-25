CONFIGURABLES = YAML.load_file(
  "#{Rails.root.to_s}/config/configurable_values.yml"
).with_indifferent_access
