class Role < ActiveRecord::Base
  has_ancestry

  has_many :admin_users, class_name: 'AdminUser'

  validates :name, presence: true
  validates :rank, presence: true

  validates_uniqueness_of :name
  validates_uniqueness_of :rank

  before_create :cannot_have_more_than_one_super_admin
  before_update :cannot_have_more_than_one_super_admin
  before_destroy :cannot_destroy_last_super_admin

  def self.generate_next_rank
    Role.all.order(:rank).last.rank + 1
  end

  def cannot_have_more_than_one_super_admin
    super_admin_count = Role.where(super_admin: true).count
    if super_admin_count == 1 and self.super_admin
      raise "Cannot have more than one super_admin in application."
    end
  end

  def cannot_destroy_last_super_admin
    super_admin_count = Role.where(super_admin: true).count
    if super_admin_count == 1 and self.super_admin
      raise "Must have at least one super_admin in application."
    end
  end
end