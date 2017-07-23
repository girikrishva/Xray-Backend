class Role < ActiveRecord::Base
  has_ancestry

  acts_as_paranoid

  has_many :admin_users, class_name: 'AdminUser'
  has_many :admin_users_audits, class_name: 'AdminUsersAudit'

  validates :name, presence: true
  validates :rank, presence: true

  validates_uniqueness_of :name
  validates_uniqueness_of :rank

  before_create :cannot_have_more_than_one_super_admin, :populate_parent_name
  before_update :cannot_have_more_than_one_super_admin, :populate_parent_name
  before_destroy :cannot_destroy_last_super_admin

# default_scope { order(updated_at: :desc) }


  def self.generate_next_rank
    Role.all.order(:rank).last.rank + 1
  end

  def cannot_have_more_than_one_super_admin
    super_admin_count = Role.where(super_admin: true).count
    if super_admin_count == 1 and self.super_admin
      errors.add(:base, I18n.t('errors.cannot_destroy_last_super_admin'))
      return false
    end
  end

  def cannot_destroy_last_super_admin
    super_admin_count = Role.where(super_admin: true).count
    if super_admin_count == 1 and self.super_admin
      errors.add(:base, I18n.t('errors.one_super_admin_role'))
      return false
    end
  end

  def populate_parent_name
    self.parent_name = Role.find(self.parent_id).name rescue nil
  end
end