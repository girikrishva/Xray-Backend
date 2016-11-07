class VacationReason < ActiveRecord::Base
  belongs_to :lookup, :class_name => 'Lookup', :foreign_key => :lookup_id

  validates :code, presence: true
  validates :as_on, presence: true
  validates :days_allowed, presence: true
  validates :lookup_id, presence: true

  before_create :lookup_id_is_a_business_unit

  validates_uniqueness_of :code, scope: [:as_on]

  def lookup_id_is_a_business_unit
    if !LookupType.find(Lookup.find(:lookup_id)).name = 'Business Units'
      false
    else
      true
    end
  end
end