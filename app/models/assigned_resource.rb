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
    'Id: [' + self.id.to_s + '], Client: [' + self.project.pipeline.client.name + '], Project: [' + self.project.name + '], Resource: [' + self.resource.resource_name + '], Skill: [' + resource.skill_name + '], Start Date: [' + self.start_date.to_s + '], End Date: [' + self.end_date.to_s + '], Hours Per Day: [' + self.hours_per_day.to_s + ']' rescue nil
  end

  def over_assignment_check
    loop_date = self.start_date
    while loop_date <= self.end_date
      over_assigned_hours = AssignedResource.assigned_hours(self.resource.admin_user_id, loop_date, loop_date) - Rails.configuration.max_work_hours_per_day
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

  def self.assigned_hours(admin_user_id, from_date, to_date)
    resource_ids = Resource.where(admin_user_id: admin_user_id).pluck(:id).to_a
    assigned_hours = 0
    AssignedResource.where('resource_id in (?)', resource_ids).each do |ar|
      assigned_hours += (ar.assignment_hours(to_date) - ar.assignment_hours(from_date) + 1)
    end
    assigned_hours
  end

  def self.assigned_hours_by_skill(admin_user_id, from_date, to_date, skill_id)
    resource_ids = Resource.where(admin_user_id: admin_user_id).pluck(:id).to_a
    assigned_hours = 0
    AssignedResource.where('resource_id in (?) and skill_id = ?', resource_ids, skill_id).each do |ar|
      assigned_hours += (ar.assignment_hours(to_date) - ar.assignment_hours(from_date) + 1)
    end
    assigned_hours
  end

  def self.assigned_hours_by_designation(admin_user_id, from_date, to_date, designation_id)
    resource_ids = Resource.where(admin_user_id: admin_user_id).pluck(:id).to_a
    assigned_hours = 0
    AssignedResource.where('resource_id in (?) and designation_id = ?', resource_ids, designation_id).each do |ar|
      assigned_hours += (ar.assignment_hours(to_date) - ar.assignment_hours(from_date) + 1)
    end
    assigned_hours
  end

  def self.working_hours(admin_user_id, from_date, to_date)
    working_days = from_date.weekdays_until(to_date)
    working_days -= AssignedResource.holidays_between(AdminUser.find(admin_user_id).business_unit_id, from_date, to_date)
    working_hours = (working_days * Rails.configuration.max_work_hours_per_day)
    working_hours
  end

  def

  assignment_hours(as_on)
    as_on = (as_on.nil?) ? Date.today : Date.parse(as_on.to_s)
    lower_date = (self.start_date < as_on) ? self.start_date : as_on
    upper_date = (as_on > self.end_date) ? self.end_date : as_on
    days_assigned = lower_date.weekdays_until(upper_date)
    days_assigned -= holidays_between(self.resource.admin_user.business_unit_id, lower_date, upper_date)
    days_assigned -= unpaid_vacation_between(self.resource.admin_user.business_unit_id, self.resource.admin_user.id, lower_date, upper_date)
    hours_assigned = days_assigned * self.hours_per_day
  end

  def assignment_cost(as_on)
    self.assignment_hours(as_on) * self.cost_rate
  end

  private

  def holidays_between(business_unit_id, start_date, end_date)
    HolidayCalendar.holidays_between(business_unit_id, start_date, end_date)
  end

  def self.holidays_between(business_unit_id, start_date, end_date)
    HolidayCalendar.holidays_between(business_unit_id, start_date, end_date)
  end

  def unpaid_vacation_between(business_unit_id, admin_user_id, start_date, end_date)
    unpaid_days = 0
    VacationPolicy.where('business_unit_id = ?', business_unit_id).each do |vp|
      if !vp.paid
        unpaid_days = Vacation.availed_days(admin_user_id, vp.vacation_code_id, end_date) - Vacation.availed_days(admin_user_id, vp.vacation_code_id, start_date)
      end
    end
    unpaid_days
  end

end