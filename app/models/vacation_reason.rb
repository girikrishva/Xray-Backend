class VacationReason < ActiveRecord::Base
  belongs_to :lookup, :class_name => 'Lookup', :foreign_key => :lookup_id

  validates :code, presence: true
  validates :as_on, presence: true
  validates :days_allowed, presence: true
  validates :lookup, presence: true

  validates_uniqueness_of :code, scope: [:as_on]
end