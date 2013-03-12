# csv2sqlite

Ruby script to parse CSV file(s) into a sqlite database. Automatically
generates the table schemas based on filenames, headers, and data types.

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

To pull this in sqlite, run the following:

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

Requires Ruby 1.9+, and the following gems:

```
gem install --no-rdoc --no-ri sequel trollop sqlite3
git clone https://github.com/dergachev/csv2sqlite.git ~/csv2sqlite
```

## Misc

* using sequel gem: http://sequel.rubyforge.org/rdoc/files/README_rdoc.html
  * http://sequel.rubyforge.org/rdoc/files/doc/schema_modification_rdoc.html
  * http://sequel.rubyforge.org/rdoc/files/doc/association_basics_rdoc.html
  * http://sqlite-ruby.rubyforge.org/sqlite3/classes/SQLite3/Database.html
  * http://sequel.rubyforge.org/rdoc/files/doc/opening_databases_rdoc.html
  * http://sequel.rubyforge.org/rdoc/classes/Sequel/Database.html#method-i-drop_table
  * https://github.com/jeremyevans/sequel/blob/master/bin/sequel (found IRB.start trick)
* sqlite3 guide: http://www.sqlite.org/sqlite.html
* This assumes Ruby 1.9's CSV library, if you are using 1.8, use [FasterCSV](http://fastercsv.rubyforge.org/)
  * https://github.com/circle/fastercsv/blob/master/lib/faster_csv.rb (had to read most of the source)
