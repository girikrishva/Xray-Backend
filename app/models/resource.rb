class Resource < ActiveRecord::Base
  belongs_to :admin_user, class_name: 'AdminUser', foreign_key: :admin_user_id
  belongs_to :skill, :class_name => 'Skill', :foreign_key => :skill_id

  validates :as_on, presence: true
  validates :bill_rate, presence: true
  validates :cost_rate, presence: true
  validates :admin_user_id, presence: true
  validates :skill_id, presence: true
  validate   :only_one_primary_skill_allowed_per_user

  validates_uniqueness_of :admin_user_id, scope: [:admin_user_id, :skill_id, :as_on]
  validates_uniqueness_of :skill_id, scope: [:admin_user_id, :skill_id, :as_on]
  validates_uniqueness_of :as_on, scope: [:admin_user_id, :skill_id, :as_on]

  def skill_name
    Skill.find(self.skill_id).name
  end

  def only_one_primary_skill_allowed_per_user
    if self.primary_skill and Resource.where(skill_id: self.skill_id, admin_user_id: self.admin_user_id, primary_skill: self.primary_skill).count >= 1
      raise "User cannot have more than one primary skill."
    end
  end
end