class AdminUser < ActiveRecord::Base
  acts_as_paranoid
  ransacker :as_on do
  end
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

# # default_scope { order(updated_at: :desc) }

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

  def self.resource_efficiency(admin_user_id, from_date, to_date, with_details)
    from_date = Date.parse(from_date)
    to_date = Date.parse(to_date)
    with_details = (with_details.to_s == 'true') ? true : false
    result = {}
    admin_user = AdminUser.find(admin_user_id).latest_snapshot(to_date)
    result['data'] = AdminUser.resource_efficiency_details(admin_user, from_date, to_date, with_details)
    result
  end

  def self.business_unit_efficiency(business_unit_id, from_date, to_date, with_details)
    from_date = Date.parse(from_date)
    to_date = Date.parse(to_date)
    with_details = (with_details.to_s == 'true') ? true : false
    result = {}
    result['data'] = AdminUser.business_unit_efficiency_details(business_unit_id, from_date, to_date, with_details)
    result
  end

  def self.overall_efficiency(from_date, to_date, with_details)
    from_date = Date.parse(from_date)
    to_date = Date.parse(to_date)
    with_details = (with_details.to_s == 'true') ? true : false
    result = {}
    result['data'] = AdminUser.overall_efficiency_details(from_date, to_date, with_details)
    result
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

  def self.resource_efficiency_details(admin_user, from_date, to_date, with_details)
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
    details['admin_user_id'] = admin_user.admin_user_id
    details['admin_user_name'] = admin_user.name
    details['active'] = admin_user.active
    details['designation'] = admin_user.designation.name
    details['associate_no'] = admin_user.associate_no
    details['manager'] = AdminUser.find(admin_user.manager_id).name rescue nil
    if with_details
      details['assigned_hours'] = assigned_hours.round(1)
      details['clocked_hours'] = clocked_hours.round(1)
      details['working_hours'] = working_hours.round(1)
      details['bill_rate'] = format_currency(bill_rate.round(0))
    end
    details['assigned_percentage'] = assigned_percentage.round(2)
    details['clocked_percentage'] = clocked_percentage.round(2)
    details['utilization_percentage'] = utilization_percentage.round(2)
    details['billing_opportunity_loss'] = format_currency(((working_hours - assigned_hours) * bill_rate).round(0))
    details
  end

  def self.business_unit_efficiency_details(business_unit_id, from_date, to_date, with_details)
    details = {}
    resource_efficiency_details = []
    AdminUser.joins(:business_unit).where('business_unit_id = ?', business_unit_id).order('business_units.name, admin_users.name').each do |au|
      admin_user = au.latest_snapshot(to_date) rescue au
      if !admin_user.nil? and !admin_user.blank?
        resource_efficiency_details << AdminUser.resource_efficiency_details(admin_user, from_date, to_date, with_details)
      end
    end
    details['business_unit'] = BusinessUnit.find(business_unit_id).name
    business_unit_assigned_percentage = (resource_efficiency_details.map { |y| y['assigned_percentage'] }.sum / resource_efficiency_details.size).round(2) rescue 0
    details['business_unit_assigned_percentage'] = business_unit_assigned_percentage
    business_unit_clocked_percentage = (resource_efficiency_details.map { |y| y['clocked_percentage'] }.sum / resource_efficiency_details.size).round(2) rescue 0
    details['business_unit_clocked_percentage'] = business_unit_clocked_percentage
    details['business_unit_utilization_percentage'] = ((business_unit_assigned_percentage * business_unit_clocked_percentage) / 100).round(2)
    details['business_unit_billing_opportunity_loss'] = format_currency(resource_efficiency_details.map { |y| currency_as_amount(y['billing_opportunity_loss']) }.sum.round(0))
    if with_details
      details['resource_efficiency_details'] = resource_efficiency_details
    end
    details
  end

  def self.overall_efficiency_details(from_date, to_date, with_details)
    details = {}
    business_unit_efficiency_details = []
    BusinessUnit.order('name').each do |bu|
      business_unit_efficiency_details << AdminUser.business_unit_efficiency_details(bu.id, from_date, to_date, with_details)
    end
    overall_assigned_percentage = (business_unit_efficiency_details.map { |y| y['business_unit_assigned_percentage'] }.sum / business_unit_efficiency_details.size).round(2) rescue 0
    details['overall_assigned_percentage'] = overall_assigned_percentage
    overall_clocked_percentage = (business_unit_efficiency_details.map { |y| y['business_unit_clocked_percentage'] }.sum / business_unit_efficiency_details.size).round(2) rescue 0
    details['overall_clocked_percentage'] = overall_clocked_percentage
    details['overall_utilization_percentage'] = ((overall_assigned_percentage * overall_clocked_percentage) / 100).round(2)
    details['overall_billing_opportunity_loss'] = format_currency(business_unit_efficiency_details.map { |y| currency_as_amount(y['business_unit_billing_opportunity_loss']) }.sum.round(0))
    if with_details
      details['business_unit_efficiency_details'] = business_unit_efficiency_details
    end
    details
  end

  def self.get_records(id)
    users = []
    self.where(id: id).each do |user|
      users_hash = {}
      user_count = AdminUser.where(:manager_id => user.id).collect(&:id)
      user_name = user.name
      users_hash["id"] = user.id.to_s
      users_hash["name"] = user_name
      users_hash["title"] = user.designation.name
      if user_count.count() > 0
        users_hash["children"] =[]
        user_count.each do |id|
          users_hash["children"] << self.get_records(id)[0]
        end
      end
      users << users_hash
    end
    return users
  end

  def self.get_records_user_id(id)
    users = []
    self.where(id: id).each do |user|
      users_hash = {}
      user_count = AdminUser.where(:manager_id => user.id).collect(&:id)
      user_name = user.name
      users_id = user.id.to_s
      if user_count.count() > 0
        user_count.each do |id|
          self.get_records_user_id(id).each do |x|
            users << x
          end
        end
      end
      users << [user_name, users_id]
    end
    sorted_user = []
    users.each do |x|
      sorted_user << "#{x[0]}_#{x[1]}"
    end
    sorted_user_list = []
    sorted_user.sort.each do |x|
      sorted_user_list << x.split("_")
    end

    return sorted_user_list.reverse
  end

  # DEFUNCT
  # def self.bench_cost(as_on)
  #   as_on = (as_on.nil?) ? Date.today : Date.parse(as_on.to_s)
  #   bench_cost = 0
  #   total_working_hours = Rails.configuration.max_work_hours_per_day * Rails.configuration.max_work_days_per_month
  #   users_universe = AdminUser.where('date_of_leaving is null or date_of_leaving > ?', as_on).order('name')
  #   users_universe.each do |uu|
  #     assigned_hours = AssignedResource.assigned_hours(uu.id, as_on.at_beginning_of_month, as_on.at_end_of_month) rescue 0
  #     bench_cost += (total_working_hours - assigned_hours) * uu.cost_rate
  #   end
  #   format_currency(bench_cost)
  # end

  # DEFUNCT
  # def self.assigned_cost(as_on)
  #   as_on = (as_on.nil?) ? Date.today : Date.parse(as_on.to_s)
  #   assigned_cost = 0
  #   users_universe = AdminUser.where('date_of_leaving is null or date_of_leaving > ?', as_on).order('name')
  #   users_universe.each do |uu|
  #     assigned_hours = AssignedResource.assigned_hours(uu.id, as_on.at_beginning_of_month, as_on.at_end_of_month) rescue 0
  #     assigned_cost += assigned_hours * uu.cost_rate
  #   end
  #   format_currency(assigned_cost)
  # end


  def self.total_resource_cost(as_on)
    as_on = (as_on.nil?) ? Date.today : Date.parse(as_on.to_s)
    x = Resource.where('as_on <= ? and primary_skill is true', as_on).group('admin_user_id').maximum('as_on')
    y = Resource.where('admin_user_id in (?)', x.keys).where('as_on in (?)', x.values).order('skill_id').group('skill_id').sum('cost_rate')
    total_resource_cost = y.values.sum * Rails.configuration.max_work_hours_per_day * Rails.configuration.max_work_days_per_month
    total_resource_cost
  end

  def self.total_assignment_cost(as_on)
    as_on = (as_on.nil?) ? Date.today : Date.parse(as_on.to_s)
    admin_user_ids = AdminUsersAudit.where('created_at <= ?', as_on).group('admin_user_id').maximum('id')
    resource_ids = Resource.where('admin_user_id in (?)', admin_user_ids.keys).pluck(:id)
    total_assignment_cost = 0
    AssignedResource.where('resource_id in (?)', resource_ids).each do |ar|
      total_assignment_cost += (ar.assignment_cost(as_on.end_of_month.to_s) - ar.assignment_cost(as_on.beginning_of_month.to_s))
    end
    total_assignment_cost
  end

  def self.total_bench_cost(as_on)
    as_on = (as_on.nil?) ? Date.today : Date.parse(as_on.to_s)
    total_bench_cost = AdminUser.total_resource_cost(as_on) - AdminUser.total_assignment_cost(as_on)
    total_bench_cost
  end

  def self.total_resource_cost_with_details(as_on)
    as_on = (as_on.nil?) ? Date.today : Date.parse(as_on.to_s)
    x = Resource.where('as_on <= ? and primary_skill is true', as_on).group('admin_user_id').maximum('as_on')
    y = Resource.where('admin_user_id in (?)', x.keys).where('as_on in (?)', x.values).joins(:admin_user).order(:name)

  end

  def self.resource_cost_for_skill(as_on, skill_id)
    as_on = (as_on.nil?) ? Date.today : Date.parse(as_on.to_s)
    x = Resource.where('as_on <= ? and primary_skill is true', as_on).group('admin_user_id').maximum('as_on')
    y = Resource.where('admin_user_id in (?)', x.keys).where('as_on in (?)', x.values).order('skill_id').group('skill_id').sum('cost_rate')
    if y.has_key?(skill_id)
      resource_cost_for_skill = y[skill_id] * Rails.configuration.max_work_hours_per_day * Rails.configuration.max_work_days_per_month
    else
      resource_cost_for_skill = 0
    end
    resource_cost_for_skill
  end

  def self.resource_cost_for_designation(as_on, designation_id)
    as_on = (as_on.nil?) ? Date.today : Date.parse(as_on.to_s)
    x = Resource.where('as_on <= ? and primary_skill is true', as_on).group('admin_user_id').maximum('as_on')
    y = Resource.where('admin_user_id in (?)', x.keys).where('as_on in (?)', x.values).joins(:admin_user).order('designation_id').group('designation_id').sum('cost_rate')
    if y.has_key?(designation_id)
      resource_cost_for_designation = y[designation_id] * Rails.configuration.max_work_hours_per_day * Rails.configuration.max_work_days_per_month
    else
      resource_cost_for_designation = 0
    end
    resource_cost_for_designation
  end

  def self.assignment_cost_for_skill(as_on, skill_id)
    as_on = (as_on.nil?) ? Date.today : Date.parse(as_on.to_s)
    admin_user_ids = AdminUsersAudit.where('created_at <= ?', as_on).group('admin_user_id').maximum('id')
    resource_ids = Resource.where('admin_user_id in (?) and skill_id = ?', admin_user_ids.keys, skill_id).pluck(:id)
    assignment_cost_for_skill = 0
    AssignedResource.where('resource_id in (?)', resource_ids).each do |ar|
      assignment_cost_for_skill += (ar.assignment_cost(as_on.end_of_month.to_s) - ar.assignment_cost(as_on.beginning_of_month.to_s))
    end
    assignment_cost_for_skill
  end

  def self.assignment_cost_for_designation(as_on, designation_id)
    as_on = (as_on.nil?) ? Date.today : Date.parse(as_on.to_s)
    admin_user_ids = AdminUsersAudit.where('created_at <= ?', as_on).group('admin_user_id').maximum('id')
    resource_ids = Resource.where('admin_user_id in (?)', admin_user_ids.keys).joins(:admin_user).where('designation_id = ?', designation_id).pluck(:id)
    assignment_cost_for_designation = 0
    AssignedResource.where('resource_id in (?)', resource_ids).each do |ar|
      assignment_cost_for_designation += (ar.assignment_cost(as_on.end_of_month.to_s) - ar.assignment_cost(as_on.beginning_of_month.to_s))
    end
    assignment_cost_for_designation
  end

  def self.bench_cost_for_skill(as_on, skill_id)
    as_on = (as_on.nil?) ? Date.today : Date.parse(as_on.to_s)
    bench_cost_for_skill = AdminUser.resource_cost_for_skill(as_on, skill_id) - AdminUser.assignment_cost_for_skill(as_on, skill_id)
    bench_cost_for_skill
  end

  def self.bench_cost_for_designation(as_on, designation_id)
    as_on = (as_on.nil?) ? Date.today : Date.parse(as_on.to_s)
    bench_cost_for_designation = AdminUser.resource_cost_for_designation(as_on, designation_id) - AdminUser.assignment_cost_for_designation(as_on, designation_id)
    bench_cost_for_designation
  end

  # DEFUNCT
  # def self.assigned_count_for_skill(as_on, skill_id)
  #   as_on = (as_on.nil?) ? Date.today : Date.parse(as_on.to_s)
  #   bench_count_for_skill = 0
  #   total_working_hours = Rails.configuration.max_work_hours_per_day * Rails.configuration.max_work_days_per_month
  #   users_universe = AdminUser.where('date_of_leaving is null or date_of_leaving > ?', as_on).order('name')
  #   users_universe.each do |uu|
  #     resource = Resource.latest_for(uu.id, as_on)
  #     if !resource.nil? and resource.skill_id == skill_id
  #       assigned_hours = AssignedResource.assigned_hours_by_skill(uu.id, as_on.at_beginning_of_month, as_on.at_end_of_month, skill_id) rescue 0
  #       if (assigned_hours / total_working_hours) * 100 >= Rails.configuration.bench_threshold
  #         bench_count_for_skill += 1
  #       end
  #     end
  #   end
  #   bench_count_for_skill
  # end

  # DEFUNCT
  # def self.assigned_count_for_designation(as_on, designation_id)
  #   as_on = (as_on.nil?) ? Date.today : Date.parse(as_on.to_s)
  #   bench_count_for_designation = 0
  #   total_working_hours = Rails.configuration.max_work_hours_per_day * Rails.configuration.max_work_days_per_month
  #   users_universe = AdminUser.where('date_of_leaving is null or date_of_leaving > ?', as_on).order('name')
  #   users_universe.each do |uu|
  #     resource = Resource.latest_for(uu.id, as_on)
  #     if !resource.nil? and resource.admin_user.designation_id == designation_id
  #       assigned_hours = AssignedResource.assigned_hours_by_designation(uu.id, as_on.at_beginning_of_month, as_on.at_end_of_month, designation_id) rescue 0
  #       if (assigned_hours / total_working_hours) * 100 >= Rails.configuration.bench_threshold
  #         bench_count_for_designation += 1
  #       end
  #     end
  #   end
  #   bench_count_for_designation
  # end

  # DEFUNCT
  # def self.bench_count_for_designation(as_on, designation_id)
  #   as_on = (as_on.nil?) ? Date.today : Date.parse(as_on.to_s)
  #   bench_count_for_designation = 0
  #   total_working_hours = Rails.configuration.max_work_hours_per_day * Rails.configuration.max_work_days_per_month
  #   users_universe = AdminUser.where('date_of_leaving is null or date_of_leaving > ?', as_on).order('name')
  #   users_universe.each do |uu|
  #     resource = Resource.latest_for(uu.id, as_on)
  #     if !resource.nil? and resource.admin_user.designation_id == designation_id
  #       assigned_hours = AssignedResource.assigned_hours_by_designation(uu.id, as_on.at_beginning_of_month, as_on.at_end_of_month, designation_id) rescue 0
  #       if (assigned_hours / total_working_hours) * 100 < Rails.configuration.bench_threshold
  #         bench_count_for_designation += 1
  #       end
  #     end
  #   end
  #   bench_count_for_designation
  # end

  def self.total_resource_count(as_on)
    as_on = (as_on.nil?) ? Date.today : Date.parse(as_on.to_s)
    x = Resource.where('as_on <= ?', as_on).group('admin_user_id').maximum('as_on')
    y = Resource.where('admin_user_id in (?)', x.keys).where('as_on in (?)', x.values).order('skill_id').group('skill_id').count('admin_user_id')
    total_resource_count = y.values.sum
  end

  def self.total_assignment_count(as_on)
    as_on = (as_on.nil?) ? Date.today : Date.parse(as_on.to_s)
    admin_user_ids = AdminUsersAudit.where('created_at <= ?', as_on).group('admin_user_id').maximum('id')
    resource_ids = Resource.where('admin_user_id in (?)', admin_user_ids.keys).pluck(:id)
    assigned_hours = {}
    AssignedResource.where('resource_id in (?)', resource_ids).each do |ar|
      admin_user_id = ar.resource.admin_user.id
      if assigned_hours.has_key?(admin_user_id)
        assigned_hours[admin_user_id] += (ar.assignment_hours(as_on.end_of_month.to_s) - ar.assignment_hours(as_on.beginning_of_month.to_s))
      else
        assigned_hours[admin_user_id] = (ar.assignment_hours(as_on.end_of_month.to_s) - ar.assignment_hours(as_on.beginning_of_month.to_s))
      end
    end
    total_assignment_count = 0
    assigned_hours.keys.each do |admin_user_id|
      if (assigned_hours[admin_user_id] * 100 / (Rails.configuration.max_work_hours_per_day * Rails.configuration.max_work_days_per_month)) >= Rails.configuration.bench_threshold
        total_assignment_count += 1
      end
    end
    total_assignment_count
  end

  def self.total_bench_count(as_on)
    as_on = (as_on.nil?) ? Date.today : Date.parse(as_on.to_s)
    total_bench_count = AdminUser.total_resource_count(as_on) - AdminUser.total_assignment_count(as_on)
  end

  def self.resource_count_for_skill(as_on, skill_id)
    as_on = (as_on.nil?) ? Date.today : Date.parse(as_on.to_s)
    x = Resource.where('as_on <= ?', as_on).group('admin_user_id').maximum('as_on')
    y = Resource.where('admin_user_id in (?)', x.keys).where('as_on in (?)', x.values).order('skill_id').group('skill_id').count('admin_user_id')
    if y.has_key?(skill_id)
    resource_count_for_skill = y[skill_id]
    else
      resource_count_for_skill = 0
    end
    resource_count_for_skill
  end

  def self.assignment_count_for_skill(as_on, skill_id)
    as_on = (as_on.nil?) ? Date.today : Date.parse(as_on.to_s)
    admin_user_ids = AdminUsersAudit.where('created_at <= ?', as_on).group('admin_user_id').maximum('id')
    resource_ids = Resource.where('admin_user_id in (?) and skill_id = ?', admin_user_ids.keys, skill_id).pluck(:id)
    assigned_hours = {}
    AssignedResource.where('resource_id in (?)', resource_ids).each do |ar|
      admin_user_id = ar.resource.admin_user.id
      if assigned_hours.has_key?(admin_user_id)
        assigned_hours[admin_user_id] += (ar.assignment_hours(as_on.end_of_month.to_s) - ar.assignment_hours(as_on.beginning_of_month.to_s))
      else
        assigned_hours[admin_user_id] = (ar.assignment_hours(as_on.end_of_month.to_s) - ar.assignment_hours(as_on.beginning_of_month.to_s))
      end
    end
    assignment_count_for_skill = 0
    assigned_hours.keys.each do |admin_user_id|
      if (assigned_hours[admin_user_id] * 100 / (Rails.configuration.max_work_hours_per_day * Rails.configuration.max_work_days_per_month)) >= Rails.configuration.bench_threshold
        assignment_count_for_skill += 1
      end
    end
    assignment_count_for_skill
  end

  def self.resource_count_for_designation(as_on, designation_id)
    as_on = (as_on.nil?) ? Date.today : Date.parse(as_on.to_s)
    x = Resource.where('as_on <= ?', as_on).group('admin_user_id').maximum('as_on')
    y = Resource.where('admin_user_id in (?)', x.keys).where('as_on in (?)', x.values).joins(:admin_user).order('designation_id').group('designation_id').count('admin_user_id')
    if y.has_key?(designation_id)
      resource_count_for_designation = y[designation_id]
    else
      resource_count_for_designation = 0
    end
    resource_count_for_designation
  end

  def self.assignment_count_for_designation(as_on, designation_id)
    as_on = (as_on.nil?) ? Date.today : Date.parse(as_on.to_s)
    admin_user_ids = AdminUsersAudit.where('created_at <= ?', as_on).group('admin_user_id').maximum('id')
    resource_ids = Resource.where('admin_user_id in (?)', admin_user_ids.keys).joins(:admin_user).where('designation_id = ?', designation_id).pluck(:id)
    assigned_hours = {}
    AssignedResource.where('resource_id in (?)', resource_ids).each do |ar|
      admin_user_id = ar.resource.admin_user.id
      if assigned_hours.has_key?(admin_user_id)
        assigned_hours[admin_user_id] += (ar.assignment_hours(as_on.end_of_month.to_s) - ar.assignment_hours(as_on.beginning_of_month.to_s))
      else
        assigned_hours[admin_user_id] = (ar.assignment_hours(as_on.end_of_month.to_s) - ar.assignment_hours(as_on.beginning_of_month.to_s))
      end
    end
    assignment_count_for_designation = 0
    assigned_hours.keys.each do |admin_user_id|
      if (assigned_hours[admin_user_id] * 100 / (Rails.configuration.max_work_hours_per_day * Rails.configuration.max_work_days_per_month)) >= Rails.configuration.bench_threshold
        assignment_count_for_designation += 1
      end
    end
    assignment_count_for_designation
  end

  def self.bench_count_for_skill(as_on, skill_id)
    as_on = (as_on.nil?) ? Date.today : Date.parse(as_on.to_s)
    bench_count_for_skill = AdminUser.resource_count_for_skill(as_on, skill_id) - AdminUser.assignment_count_for_skill(as_on, skill_id)
    bench_count_for_skill
  end

  def self.bench_count_for_designation(as_on, designation_id)
    as_on = (as_on.nil?) ? Date.today : Date.parse(as_on.to_s)
    bench_count_for_designation = AdminUser.resource_count_for_designation(as_on, designation_id) - AdminUser.assignment_count_for_designation(as_on, designation_id)
    bench_count_for_designation
  end
end
