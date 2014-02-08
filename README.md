
# fluent-plugin-mysql-prepared-statement, a plugin for [Fluentd](http://fluentd.org) [![Build Status](https://secure.travis-ci.org/toyama0919/fluent-plugin-mysql-prepared-statement.png?branch=master)](http://travis-ci.org/toyama0919/fluent-plugin-mysql-prepared-statement)


fluent plugin mysql prepared statement query

## Installation

### td-agent(Linux)

    /usr/lib64/fluent/ruby/bin/fluent-gem install fluent-plugin-mysql-prepared-statement

### td-agent(Mac)

    sudo /usr/local/Cellar/td-agent/1.1.XX/bin/fluent-gem install fluent-plugin-mysql-prepared-statement

### fluentd only

    gem install fluent-plugin-mysql-prepared-statement


## Parameters

param|value
--------|------
output_tag|output tag(require)
host|database host(default: 127.0.0.1)
port|database port(default: 3306)
database|database name(require)
username|user(require)
password|password(default: blank)
key_names|prepared statement value(require)
sql|running sql , prepared statement query(require)

## Configuration Example(select)

```
<match mysql.input>
  type mysql_prepared_statement
  output_tag mysql.output
  host localhost
  database test_app_development
  username root
  password hogehoge
  key_names id,user_name
  sql select * from users where id = ? and user_name = ?
  flush_interval 10s
</match>
```

Assume following input is coming:

```js
mysql.input {"id":"1", "user_name":"toyama"}
```

then output becomes as below (indented):

```js
mysql.output {"id":122,"user_name":"toyama","created_at":"2014-01-01 19:10:27 +0900","updated_at":"2014-01-01 19:10:27 +0900"}
```

running query =>[select * from users where id = 1 and user_name = 'toyama']


## Configuration Example(insert)

```
<match mysql.input>
  type mysql_prepared_statement
  output_tag mysql.output
  host localhost
  database test_app_development
  username root
  password hogehoge
  key_names user_name
  sql INSERT INTO users ( user_name,created_at,updated_at) VALUES (?,now(),now())
  flush_interval 10s
</match>
```

Assume following input is coming:

```js
mysql.input {"id":"1", "user_name":"toyama"}
```

no output by insert or update

running query =>[INSERT INTO users ( user_name,created_at,updated_at) VALUES ('toyama',now(),now())]



## spec

```
bundle install
rake test
```


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new [Pull Request](../../pull/new/master)

## Copyright

Copyright (c) 2013 Hiroshi Toyama. See [LICENSE](LICENSE) for details.
