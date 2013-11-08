# csv2sqlite

Ruby script to parse CSV file(s) into a sqlite database. Automatically
generates the table schemas based on filenames, headers, and data types.

*NOTE*: For an alterative implementation in python, see https://github.com/onyxfish/csvkit

## Example

Let's say you have the following data in `baby-names-10.csv`:

```csv
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
```

To create (or update) an sqlite3 database  To parse the CSV data and create or update) an sqlite database in `./babynames.db`:

```bash
ruby ~/csv2sqlite/csv2sqlite.rb baby-names-10.csv --output babynames.db
```

csv2sqlite will derive the table names from the file name, and will guess the type of each column, defaulting to String.

We can get the SQL dump of the new database by running `sqlite3 babynames.db .dump`:

```sql
PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE `baby_names_10` (`year` integer, `name` varchar(255), `percent` double precision, `sex` varchar(255));
INSERT INTO "baby_names_10" VALUES(1880,'John',0.081541,'boy');
INSERT INTO "baby_names_10" VALUES(1880,'William',0.080511,'boy');
INSERT INTO "baby_names_10" VALUES(1880,'James',0.050057,'boy');
INSERT INTO "baby_names_10" VALUES(1880,'Charles',0.045167,'boy');
INSERT INTO "baby_names_10" VALUES(1880,'George',0.043292,'boy');
INSERT INTO "baby_names_10" VALUES(1880,'Frank',0.02738,'boy');
INSERT INTO "baby_names_10" VALUES(1880,'Joseph',0.022229,'boy');
INSERT INTO "baby_names_10" VALUES(1880,'Thomas',0.021401,'boy');
INSERT INTO "baby_names_10" VALUES(1880,'Henry',0.020641,'boy');
COMMIT;
```

Now you can interact with the data via `sqlite3`: 

```bash
$ sqlite3 babynames.db

sqlite3> .tables
baby_names_10

sqlite> .schema
CREATE TABLE `baby_names_10` (`year` integer, `name` varchar(255), `percent` double precision, `sex` varchar(255));

sqlite> SELECT * FROM baby_names_10 WHERE percent > .05;
1880|John|0.081541|boy
1880|William|0.080511|boy
1880|James|0.050057|boy
```

For more information about how to use the sqlite3 shell, see http://www.sqlite.org/sqlite.html

Even better, you can now interact with the data via the "sequel" gem's console:

```bash
sequel sqlite://babynames.db # launches IRB with sequel preloaded

irb> DB.tables
 => [:baby_names_10]

irb> DB[:baby_names_10].select(:name, :percent).limit(2).all
  [
  [0] {
    :name => "John",
      :percent => 0.081541
  },
    [1] {
      :name => "William",
      :percent => 0.080511
    }
  ]

irb> DB[:baby_names_10].select(:name, :year, :percent).where(Sequel.like(:name, 'J%')).sql
  "SELECT `name`, `year`, `percent` FROM `baby_names_10` WHERE (`name` LIKE 'J%' ESCAPE '\\')"
```

For more info, see the following [Sequel documentation](http://sequel.rubyforge.org/documentation.html) guide pages:

* [Sequel Intro README](http://sequel.rubyforge.org/rdoc/files/README_rdoc.html)
* [Sequel cheat sheet](http://sequel.rubyforge.org/rdoc/files/doc/cheat_sheet_rdoc.html)
* [Sequel datasets](http://sequel.rubyforge.org/rdoc/files/doc/dataset_basics_rdoc.html)
* [Sequel dataset filtering](http://sequel.rubyforge.org/rdoc/files/doc/dataset_filtering_rdoc.html)
* [bin/sequel](https://github.com/jeremyevans/sequel/blob/master/doc/bin_sequel.rdoc)

## IRB Usage

The default outputting of arrays and objects in IRB is not pretty. Consider
installing the awesome_print gem to improve matters:

```bash
gem install awesome_print

cat >> ~/.irbrc <<EOT 
require "awesome_print"
AwesomePrint.irb!
EOT
```

## Usage 

```bash
Usage:
  csv2sqlite [options] TABLENAME.csv [...]

  where [options] are:
       --irb-console, -i:   Open an IRB session after loading FILES into an
                            in-memory DB
    --sqlite-console, -s:   Execute 'sqlite3 FILENAME.db' afterwards
        --output, -o <s>:   FILENAME.db where to save the sqlite database
              --help, -h:   Show this message
```

## Installation

### Via Rubygems

TODO: not implemented yet

```
sudo gem install csv2sqlite
```

### Via Bundler

I recommend installing bundler to manage gem dependencies:

```bash
gem install bundler
```

Then you can run the following to download dependencies specified csv2sqlite/Gemfile:

```bash
bundle install 
```

### Installing RVM

I recommend installing RVM (Ruby Version Manager), which makes it easy to run multiple Ruby versions.
To install RVM:

```bash
# download and execute the RVM install script
curl -L https://get.rvm.io | bash -s stable --ruby
# to have RVM work in the current terminal window:
source $HOME/.rvm/scripts/rvm 
# to have it work in all future terminal windows
echo "source $HOME/.rvm/scripts/rvm" >> ~/.bash_profile
```

## Misc resources

* using sequel gem: http://sequel.rubyforge.org/rdoc/files/README_rdoc.html
* https://github.com/jeremyevans/sequel/blob/master/bin/sequel (found IRB.start trick)
* http://sqlite-ruby.rubyforge.org/sqlite3/classes/SQLite3/Database.html
* sqlite3 guide: http://www.sqlite.org/sqlite.html
* https://github.com/circle/fastercsv/blob/master/lib/faster_csv.rb (had to read most of the source)
