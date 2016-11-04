class LookupType < ActiveRecord::Base


  has_many :lookups, :class_name => 'Lookup'
end
