class StaffingRequirement < ActiveRecord::Base
  belongs_to :pipeline, class_name: 'Pipeline', foreign_key: :pipeline_id
  belongs_to :skill, :class_name => 'Skill', :foreign_key => :skill_id
  belongs_to :designation, :class_name => 'Designation', :foreign_key => :designation_id

  has_many :assigned_resources, class_name: 'AssignedResource'

  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :number_required, presence: true
  validates :hours_per_day, presence: true
  validates :pipeline_id, presence: true
  validates :skill_id, presence: true
  validates :designation_id, presence: true

  before_create :date_check, :hours_check
  before_update :date_check, :hours_check

  def skill_name
    Skill.find(self.skill_id).name
  end

  def date_check
    if self.start_date > self.end_date
      raise I18n.t('errors.date_check')
    end
  end

  def hours_check
    if self.hours_per_day < 0 || self.hours_per_day > 24
      raise I18n.t('errors.hours_per_day')
    end
  end

  def name
    '[' + self.id.to_s + '] [' + self.start_date.to_s + '] [' + self.end_date.to_s + '] ' + self.skill.name + ', ' + self.designation.name + ', ' + self.hours_per_day.to_s + ' hours per day'
  end

  def self.ordered_lookup(pipeline_id)
    StaffingRequirement.where(pipeline_id: pipeline_id, fulfilled: nil).order(:start_date, :end_date)
  end
end