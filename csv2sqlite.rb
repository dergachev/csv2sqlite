#!/usr/bin/env ruby

require 'csv'
require 'rubygems'
require 'sequel'
require 'trollop'
require 'irb'

OPTIONS = Trollop::options do
  banner <<-EOS
Usage:
	csv2sqlite [options] TABLENAME.csv [...]

where [options] are:
EOS
  opt :irb_console,  "Open an IRB session after loading FILES into an in-memory DB"
  opt :sqlite_console,  "Execute 'sqlite3 FILENAME.db' afterwards"
  opt :output,  "FILENAME.db where to save the sqlite database", :type => :string
end

def getDatabase(filename = nil)
  if filename
    puts "Connecting to sqlite://#{filename}"
    database = Sequel.sqlite(OPTIONS[:output])
    database.test_connection # saves blank file
  else
    puts "Connecting to sqlite://:memory:"
    database = Sequel.sqlite(':memory:')
  end
  return database
end

def populateTableFromCSV(database,filename)

  #   - The CSV has a header line, if not look at :headers option in CSV.new
  #     http://ruby-doc.org/stdlib-1.9.3/libdoc/csv/rdoc/CSV.html#method-c-new
  options = { :headers    => true,
              :header_converters => :symbol,
              :converters => :all  }
  rows = []
  CSV.foreach(filename, options) do |row|
      rows.push(Hash[row.headers.zip(row.fields)])
  end

  headers = rows[0].keys

  tablename = File.basename(filename, '.csv').gsub(/[^0-9a-zA-Z_]/,'_').to_sym

  puts "Dropping and re-creating table #{tablename}"
  DB.drop_table? tablename
  DB.create_table tablename do
    # primary_key :id
    # Float :price
    headers.each do |col|
      String col
    end
  end
  rows.each do |row|
    database[tablename].insert(row)
  end
end

def launchConsole(database)
  require 'pp'
  require 'irb'

  puts "You can now interact with the database via DB. Examples:"
  puts "  DB.tables #=> SHOW tables"
  puts "  ds = DB[:posts] #=> SELECT * FROM posts"
  puts "  ds = DB[:posts].where(:id => 1) #==> SELECT * FROM posts WHERE id => 1"
  puts "  puts DB[:posts].all ; nil #=> executes query, pretty prints results" 
  puts "See http://sequel.rubyforge.org/rdoc/files/doc/dataset_basics_rdoc.html"
  puts "Type 'sqlite3' to enter sqlite3 console"

  puts "Available tables: "
  database.tables.each do |table|
    puts " #{table.to_s} - #{DB[table].count.to_s} records"
  end
  IRB.start
  exit;
end

def launchSqliteConsole(filename)
  Kernel.exec('sqlite3 ' + filename)
end

DB = getDatabase(OPTIONS[:output])

Trollop.die "Missing CSV file argument(s)" unless ARGV.count > 0
until ARGV.empty? do 
  file = ARGV.shift
  File.exists?(file) or Trollop.die "Invalid file: #{file}" 
  puts "Parsing file #{file}"
  populateTableFromCSV(DB, file)
end

launchConsole(DB) if OPTIONS[:irb_console]
if OPTIONS[:sqlite_console] 
  Trollop.die "--sqlite-console requires --output" unless OPTIONS[:output]
  launchSqliteConsole(OPTIONS[:output]) 
end

__END__

$ ruby search-csv.rb
year: 1911           name: Ruby           percent: 0.007637    sex: girl

* This assumes Ruby 1.9's CSV library, if you are using 1.8, use FasterCSV.
* http://sequel.rubyforge.org/rdoc/classes/Sequel/Database.html#method-i-drop_table


  
