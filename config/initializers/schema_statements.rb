module ActiveRecord
  module ConnectionAdapters
    module SQLServer
      module SchemaStatements

        SCHEMA_EXPIRES_IN = 1.day

        def views_real_column_name(table_name, column_name)
          view_definition = Rails.cache.fetch("sqlserver_table_view_info_#{table_name}", expires_in: SCHEMA_EXPIRES_IN) do
            view_information(table_name)[:VIEW_DEFINITION]
          end
          return column_name unless view_definition
          # match_data = view_definition.match(/([\w-]*)\s+as\s+#{column_name}/im)
          # ret = match_data ? match_data[1] : column_name
          ret = column_name
          ret
        end

        def column_definitions(table_name)
          col_defn = Rails.cache.fetch("sqlserver_col_defns_#{table_name}", expires_in: SCHEMA_EXPIRES_IN) do
            identifier = if database_prefix_remote_server?
                           SQLServer::Utils.extract_identifiers("#{database_prefix}#{table_name}")
                         else
                           SQLServer::Utils.extract_identifiers(table_name)
                         end
            database    = identifier.fully_qualified_database_quoted
            view_exists = view_exists?(table_name)
            view_tblnm  = view_table_name(table_name) if view_exists
            sql = %{
              SELECT DISTINCT
              #{lowercase_schema_reflection_sql('columns.TABLE_NAME')} AS table_name,
              #{lowercase_schema_reflection_sql('columns.COLUMN_NAME')} AS name,
              columns.DATA_TYPE AS type,
              columns.COLUMN_DEFAULT AS default_value,
              columns.NUMERIC_SCALE AS numeric_scale,
              columns.NUMERIC_PRECISION AS numeric_precision,
              columns.DATETIME_PRECISION AS datetime_precision,
              columns.COLLATION_NAME AS [collation],
              columns.ordinal_position,
              CASE
                WHEN columns.DATA_TYPE IN ('nchar','nvarchar','char','varchar') THEN columns.CHARACTER_MAXIMUM_LENGTH
                ELSE COL_LENGTH('#{database}.'+columns.TABLE_SCHEMA+'.'+columns.TABLE_NAME, columns.COLUMN_NAME)
              END AS [length],
              CASE
                WHEN columns.IS_NULLABLE = 'YES' THEN 1
                ELSE NULL
              END AS [is_nullable],
              CASE
                WHEN KCU.COLUMN_NAME IS NOT NULL AND TC.CONSTRAINT_TYPE = N'PRIMARY KEY' THEN 1
                ELSE NULL
              END AS [is_primary],
              c.is_identity AS [is_identity]
              FROM #{database}.INFORMATION_SCHEMA.COLUMNS columns
              LEFT OUTER JOIN #{database}.INFORMATION_SCHEMA.TABLE_CONSTRAINTS AS TC
                ON TC.TABLE_NAME = columns.TABLE_NAME
                AND TC.TABLE_SCHEMA = columns.TABLE_SCHEMA
                AND TC.CONSTRAINT_TYPE = N'PRIMARY KEY'
              LEFT OUTER JOIN #{database}.INFORMATION_SCHEMA.KEY_COLUMN_USAGE AS KCU
                ON KCU.COLUMN_NAME = columns.COLUMN_NAME
                AND KCU.CONSTRAINT_NAME = TC.CONSTRAINT_NAME
                AND KCU.CONSTRAINT_CATALOG = TC.CONSTRAINT_CATALOG
                AND KCU.CONSTRAINT_SCHEMA = TC.CONSTRAINT_SCHEMA
              INNER JOIN #{database}.sys.schemas AS s
                ON s.name = columns.TABLE_SCHEMA
                AND s.schema_id = s.schema_id
              INNER JOIN #{database}.sys.objects AS o
                ON s.schema_id = o.schema_id
                AND o.is_ms_shipped = 0
                AND o.type IN ('U', 'V')
                AND o.name = columns.TABLE_NAME
              INNER JOIN #{database}.sys.columns AS c
                ON o.object_id = c.object_id
                AND c.name = columns.COLUMN_NAME
              WHERE columns.TABLE_NAME = #{prepared_statements ? '@0' : quote(identifier.object)}
                AND columns.TABLE_SCHEMA = #{identifier.schema.blank? ? 'schema_name()' : (prepared_statements ? '@1' : quote(identifier.schema))}
              ORDER BY columns.ordinal_position
            }.gsub(/[ \t\r\n]+/, ' ').strip
            binds = []
            nv128 = SQLServer::Type::UnicodeVarchar.new limit: 128
            binds << Relation::QueryAttribute.new('TABLE_NAME', identifier.object, nv128)
            binds << Relation::QueryAttribute.new('TABLE_SCHEMA', identifier.schema, nv128) unless identifier.schema.blank?
            results = sp_executesql(sql, 'SCHEMA', binds)
            ret = results.map do |ci|
              ci = ci.symbolize_keys
              ci[:_type] = ci[:type]
              ci[:table_name] = view_tblnm || table_name
              ci[:type] = case ci[:type]
                          when /^bit|image|text|ntext|datetime$/
                            ci[:type]
                          when /^datetime2|datetimeoffset$/i
                            "#{ci[:type]}(#{ci[:datetime_precision]})"
                          when /^time$/i
                            "#{ci[:type]}(#{ci[:datetime_precision]})"
                          when /^numeric|decimal$/i
                            "#{ci[:type]}(#{ci[:numeric_precision]},#{ci[:numeric_scale]})"
                          when /^float|real$/i
                            "#{ci[:type]}"
                          when /^char|nchar|varchar|nvarchar|binary|varbinary|bigint|int|smallint$/
                            ci[:length].to_i == -1 ? "#{ci[:type]}(max)" : "#{ci[:type]}(#{ci[:length]})"
                          else
                            ci[:type]
                          end
              ci[:default_value],
                  ci[:default_function] = begin
                default = ci[:default_value]
                if default.nil? && view_exists
                  default = column_default(database, view_tblnm, views_real_column_name(table_name, ci[:name]))
                end
                case default
                when nil
                  [nil, nil]
                when /\A\((\w+\(\))\)\Z/
                  default_function = Regexp.last_match[1]
                  [nil, default_function]
                when /\A\(N'(.*)'\)\Z/m
                  string_literal = SQLServer::Utils.unquote_string(Regexp.last_match[1])
                  [string_literal, nil]
                when /CREATE DEFAULT/mi
                  [nil, nil]
                else
                  type = case ci[:type]
                         when /smallint|int|bigint/ then ci[:_type]
                         else ci[:type]
                         end
                  value = default.match(/\A\((.*)\)\Z/m)[1]
                  value = select_value "SELECT CAST(#{value} AS #{type}) AS value", 'SCHEMA'
                  [value, nil]
                end
              end
              ci[:null] = ci[:is_nullable].to_i == 1
              ci.delete(:is_nullable)
              ci[:is_primary] = ci[:is_primary].to_i == 1
              ci[:is_identity] = ci[:is_identity].to_i == 1 unless [TrueClass, FalseClass].include?(ci[:is_identity].class)
              ci
            end
            ret
          end
          col_defn
        end

        def column_default(database, table_name, col_name)
          columns = Rails.cache.fetch("sqlserver_def_col_#{database}_#{table_name}", expires_in: SCHEMA_EXPIRES_IN) do
            result = select "
                  SELECT c.COLUMN_NAME, c.COLUMN_DEFAULT
                  FROM #{database}.INFORMATION_SCHEMA.COLUMNS c
                  WHERE c.TABLE_NAME = '#{table_name}'".squish, 'SCHEMA'
            default_column_values = {}
            result.each do |row|
              default_column_values[row["COLUMN_NAME"]] = row["COLUMN_DEFAULT"]
            end
            default_column_values
          end
          columns[col_name]
        end

      end
    end
  end
end
