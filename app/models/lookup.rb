class Lookup < ActiveRecord::Base


  belongs_to :lookup_type, :class_name => 'LookupType', :foreign_key => :lookup_type_id
end
