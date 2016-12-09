class VacationPolicy < ActiveRecord::Base
  belongs_to :vacation_code, :class_name => 'VacationCode', :foreign_key => :vacation_code_id
  belongs_to :business_unit, :class_name => 'BusinessUnit', :foreign_key => :business_unit_id

  validates :vacation_code_id, presence: true
  validates :as_on, presence: true
  validates :days_allowed, presence: true
  # validates :business_unit_id, presence: true

  # validates_uniqueness_of :business_unit, scope: [:vacation_code, :as_on]
  validates_uniqueness_of :vacation_code, scope: [:business_unit, :as_on]

  def business_unit_name
    self.business_unit.name
  end

  def self.latest_days_allowed(business_unit_id, vacation_code_id, as_on)
    VacationPolicy.where('business_unit_id = ? and vacation_code_id = ? and as_on <= ?', business_unit_id, vacation_code_id, as_on).order('as_on desc').first.days_allowed
  end
end