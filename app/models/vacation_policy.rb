class VacationPolicy < ActiveRecord::Base
  belongs_to :vacation_code, :class_name => 'Lookup', :foreign_key => :vacation_code_id
  belongs_to :business_unit, :class_name => 'Lookup', :foreign_key => :business_unit_id

  validates :vacation_code, presence: true
  validates :as_on, presence: true
  validates :days_allowed, presence: true
  validates :business_unit, presence: true

  validates_uniqueness_of :business_unit, scope: [:vacation_code, :as_on]
  validates_uniqueness_of :vacation_code, scope: [:business_unit, :as_on]
end