# -*- encoding : utf-8 -*-
module Fluent
  class Fluent::MysqlPreparedStatementOutput < Fluent::BufferedOutput
    Fluent::Plugin.register_output('mysql_prepared_statement', self)

    # Define `router` method of v0.12 to support v0.10.57 or earlier
    unless method_defined?(:router)
      define_method("router") { Engine }
    end

    config_param :host, :string, :default => "127.0.0.1"
    config_param :output_tag, :string
    config_param :port, :integer, :default => 3306
    config_param :database, :string
    config_param :username, :string
    config_param :password, :string, :default => ''

    config_param :key_names, :string, :default => nil
    config_param :sql, :string, :default => nil

    attr_accessor :handler

    def initialize
      super
      require 'mysql2-cs-bind'
    end

    def configure(conf)
      super

      if @sql.nil?
        raise Fluent::ConfigError, "sql MUST be specified, but missing"
      end

      if @key_names.nil?
        raise Fluent::ConfigError, "key_names MUST be specified, but missing"
      end

      @key_names = @key_names.split(',')
      @format_proc = Proc.new{|tag, time, record| @key_names.map{|k| record[k]}}

      begin
        Mysql2::Client.pseudo_bind(@sql, @key_names.map{|n| nil})
      rescue ArgumentError => e
        raise Fluent::ConfigError, "mismatch between sql placeholders and key_names"
      end

      $log.info "sql ->[#{@sql}]"
    end

    def start
      super
    end

    def shutdown
      super
    end

    def format(tag, time, record)
      [tag, time, @format_proc.call(tag, time, record)].to_msgpack
    end

    def client
      Mysql2::Client.new({
          :host => @host,
          :port => @port,
          :username => @username,
          :password => @password,
          :database => @database,
          :flags => Mysql2::Client::MULTI_STATEMENTS
        })
    end

    def write(chunk)
      @handler = client
      $log.info "adding mysql_query job: "
      chunk.msgpack_each { |tag, time, data|
        results = get_exec_result(data)
        results.each{|result|
          router.emit(@output_tag, Fluent::Engine.now, result)
        }
      }
      @handler.close
    end

    def get_exec_result(data)
      results = Array.new
      stmt = @handler.xquery(@sql, data)
      return results if stmt.nil?
      stmt.each do |row|
        results.push(row)
      end
      return results
    end
  end
end
