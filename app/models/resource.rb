class Resource < ActiveRecord::Base
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

  def skill_name
    Skill.find(self.skill_id).name
  end

  def only_one_primary_skill_allowed_per_user
    if self.primary_skill and Resource.where(admin_user_id: self.admin_user_id, primary_skill: self.primary_skill).count > 1
      raise "User cannot have more than one primary skill."
    end
  end

  def name
    self.admin_user.name
  end

  def is_latest
    if self.id == Resource.where(skill_id: self.skill_id, admin_user_id: self.admin_user_id).order(:as_on).last.id
      return true
    else
      return false
    end
  end

  def self.latest
    latest_ids = []
    Resource.all.each do |resource|
      if resource.id == Resource.where(skill_id: resource.skill_id, admin_user_id: resource.admin_user_id).order(:as_on).last.id
        latest_ids << resource.id
      end
    end
    Resource.where(id: latest_ids)
  end

  def self.ordered_lookup
    AdminUser.select("resources.id, admin_users.name").joins(:resources)
  end

  def self.resources_for_staffing(staffing_requirement_id)
    staffing_requirement = StaffingRequirement.find(staffing_requirement_id)
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
      max_as_on = Resource.where('id in (?) and skill_id = ?', resource_ids, resource.skill_id).order(:as_on).last.as_on
      if resource.as_on == max_as_on
        resource_ids_for_max_as_on << resource_id
      end
    end
    AdminUser.select("resources.id, admin_users.name").joins(:resources).where('resources.id in (?)', resource_ids_for_max_as_on).order('admin_users.name')
  end
end