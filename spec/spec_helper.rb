Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each {|f| require f}

require 'greenwich'

RSpec.configure do |config|
  config.before do
    load File.join(File.dirname(__FILE__), "model.rb")
  end
end
