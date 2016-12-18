class AssignedResource < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :project, class_name: 'Project', foreign_key: :project_id
  belongs_to :skill_code, :class_name => 'Skill', :foreign_key => :skill_id
  belongs_to :designation_code, :class_name => 'Designation', :foreign_key => :designation_id
  belongs_to :resource, :class_name => 'Resource', :foreign_key => :resource_id
  belongs_to :staffing_requirement, class_name: 'StaffingRequirement', foreign_key: :staffing_requirement_id

  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :hours_per_day, presence: true
  validates :project_id, presence: true
  validates :skill_id, presence: true
  validates :designation_id, presence: true
  validates :resource_id, presence: true
  validates :staffing_requirement_id, presence: true
  validates :bill_rate, presence: true
  validates :cost_rate, presence: true

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

  def staffing_requirement_name
    StaffingRequirement.find(self.staffing_requirement_id).name
  end

  def assigned_resource_name
    'Id: [' + self.id.to_s + '], Client: [' + self.project.pipeline.client.name + '], Project: [' + self.project.name + '], Resource: [' + self.resource.resource_name + '], Skill: [' + resource.skill_name + '], Start Date: [' + self.start_date.to_s + '], End Date: [' + self.end_date.to_s + '], Hours Per Day: [' + self.hours_per_day.to_s + ']'
  end

  def self.ordered_lookup
    AssignedResource.all.order(:start_date)
  end
end