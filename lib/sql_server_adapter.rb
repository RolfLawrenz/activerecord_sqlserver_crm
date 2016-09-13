# The code changes here are for using failover. Add you secondary host in database.yml as a slave. For example
#
# development:
#   adapter: sqlserver
#   host: master.db.int
#   port: 1433
#   database: FailoverDatabase
#   username: user
#   password: pass
#   slaves:
#     - host: slave.db.int
#
module ActiveRecord
  module ConnectionAdapters
    class SQLServerAdapter

      def connect
        config = @connection_options
        # If using host database, try connect to master again after x minutes
        if using_slave? && @switch_back_next_attempt.present? && @switch_back_next_attempt <= Time.now
          change_active_host
        end
        @connection = case config[:mode]
                      when :dblib
                        begin
                          # Attempt first connect
                          dblib_connect(config)
                        rescue
                          begin
                            dblib_connect(config)
                          rescue
                            change_active_host
                            dblib_connect(config)
                          end
                        end
                      when :odbc
                        odbc_connect(config)
                      end
        @spid = _raw_select('SELECT @@SPID', fetch: :rows).first.first
        configure_connection
      end

      def using_master?
        @active_host == @connection_options[:host]
      end

      def using_slave?
        !using_master?
      end

      def active_host=(host)
        @active_host = host
      end

      def active_host
        @active_host ||= @connection_options[:host]
      end

      def change_active_host
        slave_host = @connection_options[:slaves][0]['host'] if @connection_options[:slaves]
        return unless slave_host
        if using_master?
          self.active_host = slave_host
          # After x minutes, try using the master database again
          @switch_back_next_attempt = Time.now + 5.minute
        else
          self.active_host = @connection_options[:host]
          @switch_back_next_attempt = nil
        end
      end

      def dblib_connect(config)
        TinyTds::Client.new(
            dataserver: config[:dataserver],
            host: active_host,
            port: config[:port],
            username: config[:username],
            password: config[:password],
            database: config[:database],
            tds_version: config[:tds_version],
            appname: config_appname(config),
            login_timeout: config_login_timeout(config),
            timeout: config_timeout(config),
            encoding:  config_encoding(config),
            azure: config[:azure]
        ).tap do |client|
          if config[:azure]
            client.execute('SET ANSI_NULLS ON').do
            client.execute('SET CURSOR_CLOSE_ON_COMMIT OFF').do
            client.execute('SET ANSI_NULL_DFLT_ON ON').do
            client.execute('SET IMPLICIT_TRANSACTIONS OFF').do
            client.execute('SET ANSI_PADDING ON').do
            client.execute('SET QUOTED_IDENTIFIER ON').do
            client.execute('SET ANSI_WARNINGS ON').do
          else
            client.execute('SET ANSI_DEFAULTS ON').do
            client.execute('SET CURSOR_CLOSE_ON_COMMIT OFF').do
            client.execute('SET IMPLICIT_TRANSACTIONS OFF').do
          end
          client.execute('SET TEXTSIZE 2147483647').do
          client.execute('SET CONCAT_NULL_YIELDS_NULL ON').do
        end
      end

    end
  end
end
