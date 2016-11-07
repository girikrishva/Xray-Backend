class VacationReason < ActiveRecord::Base

  validates :code, presence: true
  validates :as_on, presence: true
  validates :days_allowed, presence: true

  validates_uniqueness_of :code, scope: [:as_on]
end