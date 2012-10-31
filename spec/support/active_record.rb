test_db_root = File.expand_path('../../../tmp/', __FILE__)
Dir.mkdir test_db_root unless Dir.exists? test_db_root

SQLite3::Database.new "#{test_db_root}/test.db"

ActiveRecord::Base.establish_connection(
  :adapter  => 'sqlite3',
  :database => 'tmp/test.db'
)

ActiveRecord::Base.connection.create_table(:model_with_time_zones) do |t|
  t.datetime :started_at_utc
  t.datetime :ended_at_utc
  t.string   :time_zone
end

RSpec.configure do |config|
  config.before(:each) do
    ActiveRecord::Base.connection.execute 'DELETE FROM model_with_time_zones'
  end

  config.after(:suite) do
    `rm -f ./tmp/test.db`
  end
end
