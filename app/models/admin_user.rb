class AdminUser < ActiveRecord::Base
  acts_as_paranoid

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :timeoutable

  belongs_to :role, class_name: 'Role', foreign_key: :role_id
  belongs_to :business_unit, class_name: 'BusinessUnit', foreign_key: :business_unit_id
  belongs_to :department, class_name: 'Department', foreign_key: :department_id
  belongs_to :designation, class_name: 'Designation', foreign_key: :designation_id
  belongs_to :manager, class_name: 'AdminUser', foreign_key: :manager_id

  has_many :admin_users_audits, class_name: 'AdminUsersAudit'
  has_many :resources, class_name: 'Resource'
  has_many :pipelines, class_name: 'Pipeline'
  has_many :pipelines_audits, class_name: 'PipelinesAudit'
  has_many :projects, class_name: 'Project'
  has_many :vacations, class_name: 'Vacation'
  has_many :admin_users_sessions, class_name: 'AdminUsersSession'

  before_create :last_super_admin_cannot_be_inactive
  after_create :create_audit_record
  before_update :at_least_one_user_must_be_super_admin, :last_super_admin_cannot_be_inactive, :create_user_session, :update_user_session
  after_update :create_audit_record
  before_destroy :cannot_destroy_last_super_admin_user
  before_create :doj_dol_date_check
  before_update :doj_dol_date_check
  before_create :deactivate_left_user
  before_update :deactivate_left_user
  before_create :check_reporting_loop
  before_update :check_reporting_loop

  def at_least_one_user_must_be_super_admin
    role_id_for_super_admin = Role.where(super_admin: true).first.id
    super_admin_user_count = AdminUser.where(role_id: role_id_for_super_admin).where.not(id: self.id).count
    if super_admin_user_count < 1 and self.role_id != role_id_for_super_admin and !self.active
      errors.add(:base, I18n.t('errors.min_one_super_admin'))
      return false
    end
  end

  def cannot_destroy_last_super_admin_user
    role_id_for_super_admin = Role.where(super_admin: true).first.id
    super_admin_user_count = AdminUser.where(role_id: role_id_for_super_admin).count
    if super_admin_user_count == 1 and self.role_id == role_id_for_super_admin
      errors.add(:base, I18n.t('errors.cannot_destroy_last_super_admin'))
      return false
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
    audit_record.date_of_joining = self.date_of_joining
    audit_record.date_of_leaving = self.date_of_leaving
    audit_record.updated_by = self.updated_by
    audit_record.ip_address = self.ip_address
    audit_record.comments = self.comments
    audit_record.manager_id = self.manager_id
    audit_record.associate_no = self.associate_no
    audit_record.bill_rate = self.bill_rate
    audit_record.cost_rate = self.cost_rate
    audit_record.save
  end

  def create_user_session
    current_sign_in_at_in_db = AdminUser.find(self.id).current_sign_in_at
    if self.current_sign_in_at != current_sign_in_at_in_db
      admin_users_session = AdminUsersSession.create(admin_user_id: self.id, session_started: self.current_sign_in_at, session_ended: self.current_sign_in_at, from_ip_address: self.ip_address)
      admin_users_session.save
    end
  end

  def update_user_session
    admin_users_session = AdminUsersSession.where('admin_user_id = ? and session_started = ?', self.id, self.current_sign_in_at).first
    if !admin_users_session.nil?
      admin_users_session.session_ended = DateTime.now
      admin_users_session.save
    end
  end

  def last_super_admin_cannot_be_inactive
    role_id_for_super_admin = Role.where(super_admin: true).first.id
    super_admin_user_count = AdminUser.where(role_id: role_id_for_super_admin).count
    if super_admin_user_count == 1 and Role.find(self.role_id).super_admin and !self.active
      errors.add(:base, I18n.t('errors.last_super_admin_inactive'))
      return false
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

  def doj_dol_date_check
    if !self.date_of_joining.blank? and !self.date_of_leaving.blank?
      if self.date_of_joining > self.date_of_leaving
        errors.add(:base, I18n.t('errors.doj_dol_date_check'))
        return false
      end
    end
  end

  def deactivate_left_user
    if !self.date_of_leaving.blank?
      self.active = false
    end
  end

  def check_reporting_loop
    @child_ids = []
    traverse_reportees(self.id)
    if @child_ids.include?(self.manager_id)
      errors.add(:base, I18n.t('errors.reporting_loop', manager_name: AdminUser.find(self.manager_id).name, manager_id: self.id, name: self.name, id: self.id))
      return false
    end
  end

  def admin_user_details
    result = {}
    result['admin_user_details'] = self
    result['business_unit'] = self.business_unit.name
    result['department'] = self.department.name
    result['designation'] = self.designation.name
    result['role'] = self.role.name
    result['manager'] = self.manager.name rescue nil
    result
  end

  def self.active_users
    AdminUser.where('active = ?', :true)
  end

  def self.resource_efficiency(admin_user_id, from_date, to_date)
    from_date = Date.parse(from_date)
    to_date = Date.parse(to_date)
    result = {}
    admin_user = AdminUser.find(admin_user_id).latest_snapshot(to_date)
    result['details'] = AdminUser.efficiency_details(admin_user, from_date, to_date)
    result
  end

  def self.business_unit_efficiency(business_unit_id, from_date, to_date)
    from_date = Date.parse(from_date)
    to_date = Date.parse(to_date)
    result = {}
    result['details'] = AdminUser.business_unit_details(business_unit_id, from_date, to_date)
    result
  end

  def self.overall_efficiency(from_date, to_date, with_details)

  end

  def latest_snapshot(as_on)
    as_on = (as_on.nil?) ? Date.today : Date.parse(as_on.to_s)
    AdminUsersAudit.where('admin_user_id = ? and created_at <= ?', self.id, as_on).order('created_at').last
  end

  private

  def traverse_reportees(root_id)
    AdminUser.where('manager_id = ?', root_id).each do |child|
      @child_ids << child.id
      traverse_reportees(child.id)
    end
  end

  def self.efficiency_details(admin_user, from_date, to_date)
    details = {}
    admin_user_id = admin_user.admin_user_id
    assigned_hours = AssignedResource.assigned_hours(admin_user_id, from_date, to_date)
    working_hours = AssignedResource.working_hours(admin_user_id, from_date, to_date)
    assigned_percentage = (assigned_hours / working_hours) * 100 rescue 0
    clocked_hours = Timesheet.clocked_hours(admin_user_id, from_date, to_date)
    clocked_percentage = (clocked_hours / assigned_hours) * 100 rescue 0
    utilization_percentage = (clocked_hours / working_hours) * 100 rescue 0
    bill_rate = Resource.latest_for(admin_user_id, to_date).bill_rate rescue AdminUser.find(admin_user_id).bill_rate
    details['business_unit'] = admin_user.business_unit.name
    details['admin_user_name'] = admin_user.name
    details['active'] = admin_user.active
    details['designation'] = admin_user.designation.name
    details['manager'] = AdminUser.find(admin_user.manager_id).name rescue nil
    details['assigned_hours'] = assigned_hours
    details['clocked_hours'] = clocked_hours
    details['working_hours'] = working_hours
    details['bill_rate'] = bill_rate
    details['assigned_percentage'] = assigned_percentage.round(2)
    details['clocked_percentage'] = clocked_percentage.round(2)
    details['utilization_percentage'] = utilization_percentage.round(2)
    details['billing_opportunity_loss'] = (working_hours - assigned_hours) * bill_rate
    details
  end

  def self.business_unit_details(business_unit_id, from_date, to_date)
    details = []
    AdminUser.joins(:business_unit).order('business_units.name, admin_users.name').each do |au|
      admin_user = au.latest_snapshot(to_date) rescue au
      if !admin_user.nil? and !admin_user.blank?
        details << (AdminUser.efficiency_details(admin_user, from_date, to_date))
      end
    end
    details
  end
end
