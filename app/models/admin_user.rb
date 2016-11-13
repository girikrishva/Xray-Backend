class AdminUser < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  belongs_to :role, class_name: 'Role', foreign_key: :role_id

  has_many :admin_users_audits, class_name: 'AdminUsersAudit'

  before_update :at_least_one_user_must_be_super_admin
  before_destroy :cannot_destroy_last_super_admin_user

  def at_least_one_user_must_be_super_admin
    role_id_for_super_admin = Role.where(super_admin: true).first.id
    super_admin_user_count = AdminUser.where(role_id: role_id_for_super_admin).where.not(id: self.id).count
    if super_admin_user_count == 0 and self.role_id != role_id_for_super_admin
      raise "At least one user must be a super_admin."
    end
  end

  def cannot_destroy_last_super_admin_user
    role_id_for_super_admin = Role.where(super_admin: true).first.id
    super_admin_user_count = AdminUser.where(role_id: role_id_for_super_admin).count
    if super_admin_user_count == 1 and self.role_id == role_id_for_super_admin
      raise "Cannot destroy last super_admin user."
    end
  end
end
