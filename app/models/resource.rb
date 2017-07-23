class Resource < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :admin_user, class_name: 'AdminUser', foreign_key: :admin_user_id
  belongs_to :skill, :class_name => 'Skill', :foreign_key => :skill_id

  has_many :assigned_resources, class_name: 'AssignedResource'

  validates :as_on, presence: true
  validates :bill_rate, presence: true
  validates :cost_rate, presence: true
  validates :admin_user_id, presence: true
  validates :skill_id, presence: true
  validate :only_one_primary_skill_allowed_per_user

  validates_uniqueness_of :admin_user_id, scope: [:admin_user_id, :skill_id, :as_on]
  validates_uniqueness_of :skill_id, scope: [:admin_user_id, :skill_id, :as_on]
  validates_uniqueness_of :as_on, scope: [:admin_user_id, :skill_id, :as_on]

# default_scope { order(updated_at: :desc) }

  def skill_name
    Skill.find(self.skill_id).name
  end

  def only_one_primary_skill_allowed_per_user
    if self.deleted_at.blank? and self.primary_skill and Resource.where(admin_user_id: self.admin_user_id, primary_skill: self.primary_skill).count > 1
      errors.add(:base, I18n.t('errors.one_primary_skill'))
      return false
    end
  end

  def resource_name
    self.admin_user.name
  end

  def name
    self.admin_user.name + ' [Bill Rate: ' + self.bill_rate.to_s + ', Cost Rate: ' + self.cost_rate.to_s + ']'
  end

  def is_latest(as_on = Date.today)
    as_on = (as_on.nil?) ? Date.today : Date.parse(as_on.to_s)
    latest_resource = Resource.where('admin_user_id = ? and as_on <= ?', self.admin_user_id, as_on).order(:as_on).last rescue nil
    if !latest_resource.nil? and self.deleted_at.blank? and self.id == latest_resource.id
      return true
    else
      return false
    end
  end

  def self.ordered_lookup
    AdminUser.select("resources.id, admin_users.name").joins(:resources)
  end

  def self.resources_for_staffing(staffing_requirement_id)
    staffing_requirement = StaffingRequirement.find(staffing_requirement_id) rescue nil
    if !staffing_requirement.nil?
      resources = Resource.where('skill_id = ? and as_on <= ?', staffing_requirement.skill_id, staffing_requirement.start_date)
      resource_ids = []
      resources.each do |resource|
        if AdminUser.find(resource.admin_user_id).designation_id == staffing_requirement.designation_id
          resource_ids << resource.id
        end
      end
      resource_ids_for_max_as_on = []
      resource_ids.each do |resource_id|
        resource = Resource.find(resource_id)
        max_as_on = Resource.where('id in (?) and skill_id = ? and admin_user_id = ?', resource_ids, resource.skill_id, resource.admin_user_id).order(:as_on).last.as_on
        if resource.as_on == max_as_on
          resource_ids_for_max_as_on << resource_id
        end
      end
      AdminUser.select("resources.id, admin_users.name, resources.bill_rate, resources.cost_rate").joins(:resources).where('resources.id in (?)', resource_ids_for_max_as_on).order('admin_users.name')
    else
      nil
    end
  end

  ransacker :is_latest,
            :formatter => ->(v) {
              if v == 'true'
                Resource.latest.map(&:id)
              else
                Resource.not_latest.map(&:id)
              end
            } do |parent|
    parent.table[:id]
  end

  def self.latest_for(admin_user_id, as_on)
    as_on = (as_on.nil?) ? Date.today : Date.parse(as_on.to_s)
    resource_ids = []
    Resource.where('admin_user_id = ?', admin_user_id).each do |resource|
      if resource.is_latest(as_on)
        resource_ids << resource.id
      end
    end
    Resource.where('id in (?)', ids).order('as_on').last
  end

  def self.latest(as_on = Date.today)
    as_on = (as_on.nil?) ? Date.today : Date.parse(as_on.to_s)
    resource_ids = []
    Resource.all.each do |resource|
      if resource.is_latest(as_on)
        resource_ids << resource.id
      end
    end
    Resource.where('id in (?)', resource_ids)
  end

  def self.latest_for_skill(as_on = Date.today, skill_id)
    as_on = (as_on.nil?) ? Date.today : Date.parse(as_on.to_s)
    resource_ids = []
    Resource.all.each do |resource|
      if resource.is_latest(as_on) and resource.skill_id == skill_id
        resource_ids << resource.id
      end
    end
    Resource.where('id in (?)', resource_ids)
  end

  def self.not_latest
    resource_ids = []
    Resource.all.each do |resource|
      if !resource.is_latest
        resource_ids << resource.id
      end
    end
    Resource.where('id in (?)', resource_ids)
  end

  def self.resource_distribution_combos(as_on)
    as_on = (as_on.nil?) ? Date.today : Date.parse(as_on.to_s)
    data = []
    Resource.latest(as_on).each do |r|
      details = {}
      details['business_unit_id'] = r.admin_user.business_unit.id
      details['business_unit'] = r.admin_user.business_unit.name
      details['skill_id'] = r.skill.id
      details['skill'] = r.skill.name
      details['designation_id'] = r.admin_user.designation.id
      details['designation'] = r.admin_user.designation.name
      details['resource_details'] = Resource.resource_details(r.admin_user.business_unit.id, r.skill_id, r.admin_user.designation_id, as_on, false)
      data << details
    end
    result = {}
    temp_data = data.sort_by{|x| [x['business_unit'], x['skill'], x['designation']]}
    data = []
    data << temp_data[0] 
    temp_data.each do |r|
      if data[data.count - 1]['business_unit_id'] != r['business_unit_id'] or data[data.count - 1]['skill_id'] != r['skill_id'] or data[data.count - 1]['designation_id'] != r['designation_id']
        data << r 
      end
    end
    result['data'] = data
    result
  end

  def self.resource_details(business_unit_id, skill_id, designation_id, as_on, with_details)
    as_on = (as_on.nil?) ? Date.today : Date.parse(as_on.to_s)
    with_details = (with_details.to_s == 'true') ? true : false
    data = []
    count = 0
    total_resource_cost = 0
    Resource.latest(as_on).each do |r|
      if r.admin_user.business_unit_id == business_unit_id.to_i and r.skill_id == skill_id.to_i and r.admin_user.designation_id == designation_id.to_i
        resource_cost = (Rails.configuration.max_work_days_per_month * Rails.configuration.max_work_hours_per_day * r.cost_rate)
        if with_details
          details = {}
          details['user'] = r.admin_user.name
          details['resource_cost'] = format_currency(resource_cost)
          data << details
        end
        count += 1
        total_resource_cost += resource_cost
      end
    end
    result = {}
    result['count'] = count
    result['total_resource_cost'] = format_currency(total_resource_cost)
    result['average_resource_cost'] = format_currency((count > 0) ? (total_resource_cost / count) : 0)
    if with_details
      result['data'] = data
    end
    result
  end
end