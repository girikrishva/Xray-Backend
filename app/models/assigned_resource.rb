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

  after_save :over_assignment_check

  def skill_name
    Skill.find(self.skill_id).name
  end

  def date_check
    if self.start_date > self.end_date
      errors.add(:base, I18n.t('errors.date_check'))
      return false
    end
  end

  def hours_check
    if self.hours_per_day < 0 || self.hours_per_day > 24
      errors.add(:base, I18n.t('errors.hours_per_day'))
      return false
    end
  end

  def staffing_requirement_name
    StaffingRequirement.find(self.staffing_requirement_id).name
  end

  def assigned_resource_name
    'Id: [' + self.id.to_s + '], Client: [' + self.project.pipeline.client.name + '], Project: [' + self.project.name + '], Resource: [' + self.resource.resource_name + '], Skill: [' + resource.skill_name + '], Start Date: [' + self.start_date.to_s + '], End Date: [' + self.end_date.to_s + '], Hours Per Day: [' + self.hours_per_day.to_s + ']'
  end

  def over_assignment_check
    loop_date = self.start_date
    while loop_date <= self.end_date
      over_assigned_hours = AssignedResource.assigned_hours(self.resource.admin_user_id, loop_date) - Rails.configuration.max_work_hours_per_day
      if over_assigned_hours > 0
        admin_user_name = AdminUser.find(self.resource.admin_user_id).name
        AssignedResource.find(self.id).destroy
        errors.add(:base, I18n.t('errors.over_assignment', admin_user_name: admin_user_name, as_on: loop_date, over_assigned_hours: over_assigned_hours))
      end
      loop_date += 1
    end
  end

  def self.ordered_lookup
    AssignedResource.all.order(:start_date)
  end

  def self.assigned_hours(admin_user_id, as_on)
    resource_ids = Resource.where(admin_user_id: admin_user_id).pluck(:id).to_a
    AssignedResource.where('resource_id in (?) and start_date <= ? and end_date >= ?', resource_ids, as_on, as_on).sum(:hours_per_day)
  end

  def hours_assigned(as_on)
    as_on = Date.today.to_s if as_on.nil?
    lower_date = (self.start_date < Date.parse(as_on)) ? self.start_date : Date.parse(as_on)
    upper_date = (Date.parse(as_on) > self.end_date) ? self.end_date : Date.parse(as_on)
    hours_assigned = (upper_date - lower_date + 1) * self.hours_per_day
  end

  def assignment_cost(as_on)
    self.hours_assigned(as_on) * self.cost_rate
  end
end