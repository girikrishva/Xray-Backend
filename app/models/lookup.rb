class Lookup < ActiveRecord::Base
  belongs_to :lookup_type, :class_name => 'LookupType', :foreign_key => :lookup_type_id

  # has_many :vacation_codes, :class_name => 'VacationPolicy', foreign_key: :vacation_code_id
  # has_many :business_units, :class_name => 'VacationPolicy', foreign_key: :business_unit_id
  has_many :business_units, :class_name => 'HolidayCalendar', foreign_key: :business_unit_id

  validates :name, presence: true
  validates :rank, presence: true
  validates :lookup_type_id, presence: true

  validates_uniqueness_of :name, scope: [:lookup_type_id]
  validates_uniqueness_of :rank, scope: [:lookup_type_id]

  def self.lookups_for_name(lookup_type_name)
    Lookup.where(lookup_type_id: LookupType.where(name: lookup_type_name).first.id)
  end

  def self.max_rank_for_name(lookup_type_id)
    Lookup.where(lookup_type_id: lookup_type_id).order(:rank).last.rank + 1
  end
end
