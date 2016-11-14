class Resource < ActiveRecord::Base
  belongs_to :admin_user, class_name: 'AdminUser', foreign_key: :admin_user_id
  belongs_to :skill, :class_name => 'Skill', :foreign_key => :skill_id

  validates :as_on, presence: true
  validates :bill_rate, presence: true
  validates :cost_rate, presence: true
  validates :admin_user_id, presence: true
  validates :skill_id, presence: true

  validates_uniqueness_of :admin_user_id, scope: [:admin_user_id, :skill_id, :as_on]
  validates_uniqueness_of :skill_id, scope: [:admin_user_id, :skill_id, :as_on]
  validates_uniqueness_of :as_on, scope: [:admin_user_id, :skill_id, :as_on]
end