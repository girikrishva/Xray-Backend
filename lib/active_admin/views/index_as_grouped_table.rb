require 'active_admin/views/index_as_table'

module ActiveAdmin
  module Views
    class IndexAsGroupedTable < IndexAsTable

      def build(page_presenter, collection)
        if group_by_attribute = page_presenter[:group_by_attribute]
          collection.group_by(&group_by_attribute).sort.each do |group_name, group_collection|
            h5 group_name
            super page_presenter, group_collection
          end
        else
          super
        end
      end

    end
  end
end