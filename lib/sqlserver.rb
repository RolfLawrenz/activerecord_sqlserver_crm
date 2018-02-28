# This file comes from the activerecord_sqlserver gem and is overridden.
# It fixes 2 problems:
# 1. Primary key was looked up from database. But since we are using Views in CRM, nothing was returned for
#    primary keys. Instead we get primary key from ActiveRecord Object
# 2. With a find method, it was adding an Order by and a fetch, which is not necessary
module Arel
  module Visitors
    class SQLServer < Arel::Visitors::ToSql

      def visit_Arel_Nodes_SelectStatement o, collector
        @select_statement = o
        distinct_One_As_One_Is_So_Not_Fetch o
        if o.with
          collector = visit o.with, collector
          collector << SPACE
        end
        collector = o.cores.inject(collector) { |c,x|
          visit_Arel_Nodes_SelectCore(x, c)
        }
        # Added this line to check for orders present
        if o.orders.present?
          collector = visit_Orders_And_Let_Fetch_Happen o, collector
          collector = visit_Make_Fetch_Happen o, collector
        end
        collector
      ensure
        @select_statement = nil
      end

      def primary_Key_From_Table t
        return unless t
        # Use activerecord class, and get primary key from that rather than look in database
        arclass = t.send(:type_caster)&.send(:types)&.name&.constantize
        column_name = @connection.schema_cache.primary_keys(t.name) ||
            arclass.primary_key ||
            @connection.schema_cache.columns_hash(t.name).first.try(:second).try(:name)
        column_name ? t[column_name] : nil
      end

    end
  end
end
