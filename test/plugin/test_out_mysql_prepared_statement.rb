require 'helper'
require 'mysql2-cs-bind'

class MysqlPreparedStatementOutputTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  def create_driver(conf = CONFIG, tag='test')
    Fluent::Test::BufferedOutputTestDriver.new(Fluent::MysqlPreparedStatementOutput, tag).configure(conf)
  end

  def test_configure_error

    assert_raise(Fluent::ConfigError) {
      d = create_driver %[
        output_tag mysql.placeholder
        host localhost
        username root
        password hogehoge
        key_names id,user_name
        sql select * from users where id = ? and user_name = ?
        flush_interval 10s
      ]
    }

    # not username
    assert_raise(Fluent::ConfigError) {
      d = create_driver %[
        output_tag mysql.placeholder
        host localhost
        password hogehoge
        key_names id,user_name
        sql select * from users where id = ? and user_name = ?
        flush_interval 10s
      ]
    }
  end

  def test_configure
    # not define format(default csv)
    assert_nothing_raised(Fluent::ConfigError) {
      d = create_driver %[
        output_tag mysql.placeholder
        host localhost
        database test_app_development
        username root
        password hogehoge
        key_names id,user_name
        sql select * from users where id = ? and user_name = ?
        flush_interval 10s
      ]
    }

    assert_nothing_raised(Fluent::ConfigError) {
      d = create_driver %[
        output_tag mysql.placeholder
        host localhost
        database test_app_development
        username root
        password hogehoge
        key_names id,user_name
        sql select * from users where id = ? and user_name = ?
        flush_interval 10s
      ]
    }

    assert_nothing_raised(Fluent::ConfigError) {
      d = create_driver %[
        output_tag mysql.placeholder
        database test_app_development
        username root
        key_names id,user_name
        sql select * from users where id = ? and user_name = ?
      ]
    }
  end

  def test_query_error
    assert_raise(Fluent::ConfigError) {
      d = create_driver %[
        output_tag mysql.placeholder
        host localhost
        database rails_development
        username root
        password hogehoge
        key_names id
        sql select * from users where id = ? and user_name = ?
        flush_interval 10s
      ]
    }

    assert_raise(Fluent::ConfigError) {
      d = create_driver %[
        output_tag mysql.placeholder
        host localhost
        database rails_development
        username root
        password hogehoge
        key_names id,user_name
        sql select * from users where id = ?
        flush_interval 10s
      ]
    }
  end

end
