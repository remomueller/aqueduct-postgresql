require 'aqueduct'

module Aqueduct
  module Wrappers
    class Postgresql
      include Aqueduct::Wrapper

      def sql_codes
        { text: 'text', numeric: 'numeric', open: '"', close: '"' }
      end

      def connect
        @db_connection = PG.connect( host: @source.host, user: @source.username, password: @source.password, dbname: @source.database, port: @source.port )
      end

      def disconnect
        @db_connection.finish if @db_connection
        true
      end

      def query(sql_statement)
        results = []
        total_count = 0
        if @db_connection
          results = @db_connection.exec(sql_statement).values
          total_count = results.size
        end
        [results, total_count]
      end

      def connected?
        result = false
        error = ''
        begin
          db_connection = PG.connect( host: @source.host, user: @source.username, password: @source.password, dbname: @source.database, port: @source.port )
          status = db_connection.status
        rescue PG::Error => e
          error = "#{e.errno}: #{e.error}"
        ensure
          result = true if status == 0
          db_connection.finish if db_connection
        end
        { result: result, error: error }
      end

      def get_table_metadata
        result = {}
        error = ''
        begin
          db_connection = PG.connect( host: @source.host, user: @source.username, password: @source.password, dbname: @source.database, port: @source.port )
          if db_connection
            tables = []
            results = db_connection.exec("SELECT table_name FROM information_schema.tables WHERE table_schema = 'public';")
            tables = results.collect{|r| r["table_name"]}

            tables.sort{|table_a, table_b| table_a.downcase <=> table_b.downcase}.each do |my_table|
              results = db_connection.exec("SELECT column_name, data_type FROM information_schema.columns WHERE table_name ='#{my_table}';")
              columns = results.collect{ |r| { column: r["column_name"], datatype: r['data_type'] } }
              result[my_table] = columns.sort{|a,b| a[:column].downcase <=> b[:column].downcase}
            end
          end
        rescue PG::Error => e
          error = "#{e.errno}: #{e.error}"
        ensure
          db_connection.finish if db_connection
        end
        { result: result, error: error }
      end

      def tables
        tables = []
        error = ''
        begin
          db_connection = PG.connect( host: @source.host, user: @source.username, password: @source.password, dbname: @source.database, port: @source.port )
          if db_connection
            results = db_connection.exec("SELECT table_name FROM information_schema.tables WHERE table_schema = 'public';")
            tables = results.collect{|r| r["table_name"]}
          end
        rescue PG::Error => e
          error = "#{e.errno}: #{e.error}"
        ensure
          db_connection.finish if db_connection
        end
        { result: tables, error: error }
      end

      def table_columns(table)
        columns = []
        error = ''
        begin
          db_connection = PG.connect( host: @source.host, user: @source.username, password: @source.password, dbname: @source.database, port: @source.port )
          if db_connection
            results = db_connection.exec("SELECT column_name, data_type FROM information_schema.columns WHERE table_name ='#{table}';")
            columns = results.collect{ |r| { column: r["column_name"], datatype: r['data_type'] } }
          end
        rescue PG::Error => e
          error = "Error retrieving column information. Please make sure that this database is configured correctly."
        ensure
          db_connection.finish if db_connection
        end
        { columns: columns, error: error }
      end

      def get_all_values_for_column(table, column)
        values = []
        error = ''
        begin
          db_connection = PG.connect( host: @source.host, user: @source.username, password: @source.password, dbname: @source.database, port: @source.port )
          if db_connection
            results = db_connection.exec("SELECT column_name FROM information_schema.columns WHERE table_name ='#{table}';")
            columns = results.collect{ |r| r["column_name"] }
            column_found = columns.include?(column)

            if not column_found
              result += " <i>#{column}</i> does not exist in <i>#{@source.database}.#{table}</i>"
            else
              results = db_connection.exec("SELECT CAST(\"#{column}\" AS text) FROM \"#{table}\";")
              values = results.collect{|r| r[column.to_s]}
            end
          end
        rescue PG::Error => e
          error = "#{e.errno}: #{e.error}"
        ensure
          if db_connection
            db_connection.finish
          else
            error += " unable to connect to <i>#{@source.name}</i>"
          end
        end
        { values: values, error: error }
      end

      def column_values(table, column)
        error = ''
        result = []
        begin
          db_connection = PG.connect( host: @source.host, user: @source.username, password: @source.password, dbname: @source.database, port: @source.port )

          results = db_connection.exec("SELECT column_name FROM information_schema.columns WHERE table_name ='#{table}';")
          columns = results.collect{ |r| r["column_name"] }
          column_found = columns.include?(column)

          if column_found
            results = db_connection.exec("SELECT CAST(\"#{column}\" AS text) FROM \"#{table}\" GROUP BY \"#{column}\";")
            result = results.collect{|r| r[column.to_s]}
          end
        rescue PG::Error => e
          error = "Error: #{e.inspect}"
        ensure
          db_connection.finish if db_connection
        end
        { result: result, error: error }
      end

      def count(query_concepts, conditions, tables, join_conditions, concept_to_count)
        result = 0
        error = ''
        sql_conditions = ''
        begin
          t = Time.now
          if tables.size > 0
            sql_conditions = "SELECT count(#{concept_to_count ? 'DISTINCT ' + concept_to_count : '*'}) as record_count FROM #{tables.join(', ')} WHERE #{join_conditions.join(' and ')}#{' and ' unless join_conditions.blank?}#{conditions}"
            Rails.logger.info sql_conditions
            db_connection = PG.connect( host: @source.host, user: @source.username, password: @source.password, dbname: @source.database, port: @source.port )
            if db_connection
              results = db_connection.exec(sql_conditions)
              result = results[0]["record_count"].to_i
            end
          else
            error = "Database [#{@source.name}] Error: No tables for concepts. Database not fully mapped."
          end
        rescue PG::Error => e
          error = "Database [#{@source.name}] Error: #{e}"
        ensure
          db_connection.finish if db_connection
        end
        { result: result, error: error, sql_conditions: sql_conditions }
      end
    end
  end
end
