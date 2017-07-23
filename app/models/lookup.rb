class Lookup < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :lookup_type, :class_name => 'LookupType', :foreign_key => :lookup_type_id
  has_many :business_units, :class_name => 'HolidayCalendar', foreign_key: :business_unit_id

  validates :name, presence: true
  validates :rank, presence: true
  validates :lookup_type_id, presence: true

  validates_uniqueness_of :name, scope: [:lookup_type_id]
  validates_uniqueness_of :rank, scope: [:lookup_type_id]

  default_scope { order(updated_at: :desc) }

  def lookup_type_name
    self.lookup_type.name
  end

  def self.lookups_for_name(lookup_type_name)
    Lookup.where(lookup_type_id: LookupType.where(name: lookup_type_name).first.id).order(:rank) rescue nil
  end

  def self.max_rank_for_lookup_type(lookup_type_id)
    Lookup.where(lookup_type_id: lookup_type_id).order(:rank).last.rank + 1 rescue 1
  end

  def self.description_for_lookup(lookup_id)
    Lookup.find(lookup_id).description rescue nil
  end
end
