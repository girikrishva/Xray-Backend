class LookupType < ActiveRecord::Base
  has_many :lookups, :class_name => 'Lookup'

  validates_uniqueness_of :name
end
