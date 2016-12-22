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
    if self.deleted_at.blank? and self.id == Resource.where('skill_id = ? and admin_user_id = ? and as_on <= ?', self.skill_id, self.admin_user_id, as_on).order(:as_on).last.id
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
end