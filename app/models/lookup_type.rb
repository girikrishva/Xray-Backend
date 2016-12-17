class LookupType < ActiveRecord::Base
  acts_as_paranoid

  has_many :lookups, :class_name => 'Lookup'

  validates :name, presence: true
  validates_uniqueness_of :name
end
