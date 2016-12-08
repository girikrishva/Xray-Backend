class AdminUser < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  belongs_to :role, class_name: 'Role', foreign_key: :role_id
  belongs_to :business_unit, class_name: 'BusinessUnit', foreign_key: :business_unit_id
  belongs_to :department, class_name: 'Department', foreign_key: :department_id
  belongs_to :designation, class_name: 'Designation', foreign_key: :designation_id

  has_many :admin_users_audits, class_name: 'AdminUsersAudit'
  has_many :resources, class_name: 'Resource'
  has_many :pipelines, class_name: 'Pipeline'
  has_many :pipelines_audits, class_name: 'PipelinesAudit'
  has_many :projects, class_name: 'Project'
  has_many :vacations, class_name: 'Vacation'

  before_create :super_admin_cannot_be_inactive
  after_create :create_audit_record
  before_update :at_least_one_user_must_be_super_admin, :super_admin_cannot_be_inactive
  after_update :create_audit_record
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

  def create_audit_record
    audit_record = AdminUsersAudit.new
    audit_record.email = self.email
    audit_record.encrypted_password = self.encrypted_password
    audit_record.sign_in_count = self.sign_in_count
    audit_record.current_sign_in_at = self.current_sign_in_at
    audit_record.current_sign_in_ip = self.current_sign_in_ip.to_s
    audit_record.last_sign_in_at = self.last_sign_in_at
    audit_record.last_sign_in_ip = self.last_sign_in_ip.to_s
    audit_record.role_id = self.role_id
    audit_record.business_unit_id = self.business_unit_id
    audit_record.department_id = self.department_id
    audit_record.designation_id = self.designation_id
    audit_record.admin_user_id = self.id
    audit_record.active = self.active
    audit_record.name = self.name
    audit_record.save
  end

  def super_admin_cannot_be_inactive
    if Role.find(self.role_id).super_admin and !self.active
      raise "super_admin cannot be inactive."
    end
  end

  def active_for_authentication?
    super && self.active
  end

  def self.ordered_lookup
    AdminUser.all.order(:name)
  end

  def self.ordered_lookup_of_users_as_resource
    admin_user_ids = Resource.pluck(:admin_user_id).uniq
    AdminUser.where(id: admin_user_ids).order(:name)
  end

  def business_unit_name
    self.business_unit.name
  end

  def self.default_bill_rate(as_on = Date.today)
    Resource.where('admin_user_id = ? and as_on <= ?', self.id, as_on).order('as_on desc').first.bill_rate rescue 0
  end

  def default_cost_rate(as_on = Date.today)
    Resource.where('admin_user_id = ? and as_on <= ?', self.id, as_on).order('as_on desc').first.bill_rate rescue 0
  end
end
