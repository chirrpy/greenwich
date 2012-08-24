RSpec.configure do |config|
  # Configure RSpec to respect the alias 'pit' for pending specs
  config.alias_example_to :pit, :pending => true
end
