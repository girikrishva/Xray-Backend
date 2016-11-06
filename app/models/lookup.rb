class Lookup < ActiveRecord::Base
  belongs_to :lookup_type, :class_name => 'LookupType', :foreign_key => :lookup_type_id

  validates_uniqueness_of :value, scope: [:lookup_type_id]
  validates_uniqueness_of :rank, scope: [:lookup_type_id]
end
