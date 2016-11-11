class Role < ActiveRecord::Base
  has_many :admin_users, class_name: 'AdminUser'

  validates :name, presence: true
  validates :rank, presence: true

  validates_uniqueness_of :name
  validates_uniqueness_of :rank
  validates_uniqueness_of :super_admin

  before_destroy :cannot_destroy_last_super_admin

  def self.generate_next_rank
    Role.all.order(:rank).last.rank + 1
  end

  def cannot_destroy_last_super_admin
    super_admin_count = Role.where(super_admin: true).count
    if super_admin_count == 1
      errors.add(:base, "Must have at least one super_admin in application.")
      return false
    end
  end
end