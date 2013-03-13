#!/usr/bin/env ruby

require 'csv'
require 'rubygems'
require 'sequel'
require 'trollop'
require 'tempfile'
require 'sqlite3'

# ruby 1.8 FasterCSV compatibility
if CSV.const_defined? :Reader
  require 'fastercsv'
  Object.send(:remove_const, :CSV)
  CSV = FasterCSV
end

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

def getDatabase(filename)
  puts "Connecting to sqlite://#{filename}"
  database = Sequel.sqlite(filename)
  # database.test_connection # saves blank file
  return database
end

def populateTableFromCSV(database,filename)
  options = { :headers    => true,
              :header_converters => :symbol,
              :converters => :all  }
  data = CSV.table(filename, options)
  headers = data.headers
  tablename = File.basename(filename, '.csv').gsub(/[^0-9a-zA-Z_]/,'_').to_sym

  puts "Dropping and re-creating table #{tablename}"
  DB.drop_table? tablename
  DB.create_table tablename do
    # see http://sequel.rubyforge.org/rdoc/files/doc/schema_modification_rdoc.html
    # primary_key :id
    # Float :price
    data.by_col!.each do |columnName,rows|
      columnType = getCommonClass(rows) || String
      column columnName, columnType
    end
  end
  data.by_row!.each do |row|
    database[tablename].insert(row.to_hash)
  end
end

# 
# :call-seq:
#   getCommonClass([1,2,3])         => FixNum
#   getCommonClass([1,"bob",3])     => String
#
# Returns the class of each element in +rows+ if same for all elements, otherwise returns nil
#
def getCommonClass(rows)
  return rows.inject(rows[0].class) { |klass, el| break if klass != el.class ; klass }
end


def launchConsole(database)
  require 'irb'
  require 'pp'
  require 'yaml'

  puts "Launching IRB Console.\n\n"
  puts "You can now interact with the database via DB. Examples:"
  puts "  DB.tables #=> SHOW tables"
  puts "  ds = DB[:posts] #=> SELECT * FROM posts"
  puts "  ds = DB[:posts].where(:id => 1) #==> SELECT * FROM posts WHERE id => 1"
  puts "  puts DB[:posts].all ; nil #=> executes query, pretty prints results" 
  puts ""
  puts "See http://sequel.rubyforge.org/rdoc/files/doc/dataset_basics_rdoc.html"
  puts "To launch sqlite3 console, type 'sqlite3'"
  puts ""

  puts "Available tables: "
  database.tables.each do |table|
    puts "  DB[:#{table.to_s}] - #{DB[table].count.to_s} records"
  end
  puts ""

  IRB.start
  catch :IRB_EXIT do
    # IRB.start should trap this but doesn't
    exit
  end
end

def sqlite3()
  launchSqliteConsole()
end

def launchSqliteConsole()
  File.exists?(DB_PATH) or Trollop.die "Unable to launch sqlite3; invalid file: #{DB_PATH}" 
  puts "Launching 'sqlite3 #{DB_PATH}'. Table schema:\n"
  # NB: Using Kernel.system instead of Kernel.exec to allow Tempfile cleanup
  system("sqlite3 #{DB_PATH} '.schema'")
  puts ""
  system("sqlite3 #{DB_PATH}")
  exit
end

if OPTIONS[:output]
  DB_PATH = OPTIONS[:output]
else
  DB_TMP = Tempfile.new(['csv2sqlite','.sqlite3'])
  DB_PATH = DB_TMP.path
end

DB = getDatabase(DB_PATH)

Trollop.die "Missing CSV file argument(s)" unless ARGV.count > 0
until ARGV.empty? do 
  file = ARGV.shift
  File.exists?(file) or Trollop.die "Invalid file: #{file}" 
  puts "Parsing file #{file}"
  populateTableFromCSV(DB, file)
end

launchSqliteConsole() if OPTIONS[:sqlite_console] 
launchConsole(DB) if OPTIONS[:irb_console] || ! OPTIONS[:output]

__END__
"year","name","percent","sex"
1880,"John",0.081541,"boy"
1880,"William",0.080511,"boy"
1880,"James",0.050057,"boy"
1880,"Charles",0.045167,"boy"
1880,"George",0.043292,"boy"
1880,"Frank",0.02738,"boy"
1880,"Joseph",0.022229,"boy"
1880,"Thomas",0.021401,"boy"
1880,"Henry",0.020641,"boy"
