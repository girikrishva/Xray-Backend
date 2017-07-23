class AdminUsersAudit < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :role, class_name: 'Role', foreign_key: :role_id
  belongs_to :business_unit, class_name: 'BusinessUnit', foreign_key: :business_unit_id
  belongs_to :department, class_name: 'Department', foreign_key: :department_id
  belongs_to :designation, class_name: 'Designation', foreign_key: :designation_id
  belongs_to :admin_user, class_name: 'AdminUser', foreign_key: :admin_user_id
  belongs_to :manager, class_name: 'AdminUser', foreign_key: :manager_id

# default_scope { order(updated_at: :desc) }

  def audit_details
    I18n.t('label.updated_at') + ': ['+ datetime_as_string(self.updated_at) + '], ' + I18n.t('label.updated_by') + ': [' + self.updated_by + '], ' + I18n.t('label.ip_address') + ': [' + self.ip_address + ']' rescue nil
  end

  def self.latest(admin_user_id, as_on)
    AdminUsersAudit.where('admin_user_id = ? and created_at <= ?', admin_user_id, as_on).order('created_at').last
  end

  def self.all_latest(as_on)
    ids = []
    AdminUsersAudit.where('created_at <= ?', as_on).each do |aua|
      ids << AdminUsersAudit.latest(aua.admin_user_id, as_on).id
    end
    AdminUsersAudit.where('id in (?)', ids)
  end

  def self.active_users(as_on)
    as_on = (as_on.nil?) ? Date.today : Date.parse(as_on.to_s)
    ids = []
    AdminUsersAudit.pluck('admin_user_id').uniq.each do |aua_id|
      if (aua_latest = AdminUsersAudit.latest(aua_id, as_on)).active
        ids << aua_latest.id
      end
    end
    AdminUsersAudit.where('id in (?)', ids).order('name')
  end

  def self.inactive_users(as_on)
    as_on = (as_on.nil?) ? Date.today : Date.parse(as_on.to_s)
    ids = []
    AdminUsersAudit.pluck('admin_user_id').uniq.each do |aua_id|
      if !(aua_latest = AdminUsersAudit.latest(aua_id, as_on)).active
        ids << aua_latest.id
      end
    end
    AdminUsersAudit.where('id in (?)', ids).order('name')
  end

  def self.all_users(as_on)
    as_on = (as_on.nil?) ? Date.today : Date.parse(as_on.to_s)
    ids = []
    AdminUsersAudit.pluck('admin_user_id').uniq.each do |aua_id|
      aua_latest = AdminUsersAudit.latest(aua_id, as_on)
      ids << aua_latest.id
    end
    AdminUsersAudit.where('id in (?)', ids).order('name')
  end

  def self.active_users_outflow(from_date, to_date)
    from_date = Date.parse(from_date)
    to_date = Date.parse(to_date)
    data = {}
    lower_date = from_date
    (from_date..to_date).each do |d|
      if d > from_date
        if d == d.end_of_month or d == to_date
          days_in_month = [d - lower_date + 1, Rails.configuration.max_work_days_per_month].min
          lower_date = Date.parse((d + 1).year.to_s + '-' + (d + 1).month.to_s + '-' + '1'.to_s)
        else
          next
        end
      end
      month_year_key = AdminUsersAudit.month_year(d)
      AdminUsersAudit.active_users(d).each do |aua|
        user_key = aua.admin_user_id
        if !data.has_key?(user_key)
          data[user_key] = {}
        else
          data[user_key]['id'] = user_key
          data[user_key]['name'] = aua.name
          data[user_key]['business_unit'] = aua.business_unit.name
          data[user_key]['date_of_joining'] = aua.date_of_joining.to_s
          data[user_key]['date_of_leaving'] = aua.date_of_leaving.to_s
          data[user_key]['active'] = aua.active.to_s
          amount = days_in_month * aua.cost_rate * Rails.configuration.max_work_hours_per_day
          if !data[user_key].has_key?('user_total')
            data[user_key]['user_total'] = format_currency(amount)
          else
            data[user_key]['user_total'] = format_currency(currency_as_amount(data[user_key]['user_total']) + amount)
          end
          if !data[user_key].has_key?(month_year_key)
            data[user_key][month_year_key] = format_currency(amount)
          else
            data[user_key]['user_total'] = format_currency(currency_as_amount(data[user_key]['user_total']) + amount)
          end
        end
      end
    end
    data
  end

  def self.inactive_users_outflow(from_date, to_date)
    from_date = Date.parse(from_date)
    to_date = Date.parse(to_date)
    data = {}
    lower_date = from_date
    (from_date..to_date).each do |d|
      if d > from_date
        if d == d.end_of_month or d == to_date
          days_in_month = [d - lower_date + 1, Rails.configuration.max_work_days_per_month].min
          lower_date = Date.parse((d + 1).year.to_s + '-' + (d + 1).month.to_s + '-' + '1'.to_s)
        else
          next
        end
      end
      month_year_key = AdminUsersAudit.month_year(d)
      AdminUsersAudit.inactive_users(d).each do |aua|
        user_key = aua.admin_user_id
        if !data.has_key?(user_key)
          data[user_key] = {}
        else
          data[user_key]['id'] = user_key
          data[user_key]['name'] = aua.name
          data[user_key]['business_unit'] = aua.business_unit.name
          data[user_key]['date_of_joining'] = aua.date_of_joining.to_s
          data[user_key]['date_of_leaving'] = aua.date_of_leaving.to_s
          data[user_key]['active'] = aua.active.to_s
          amount = days_in_month * aua.cost_rate * Rails.configuration.max_work_hours_per_day
          if !data[user_key].has_key?('user_total')
            data[user_key]['user_total'] = format_currency(amount)
          else
            data[user_key]['user_total'] = format_currency(currency_as_amount(data[user_key]['user_total']) + amount)
          end
          if !data[user_key].has_key?(month_year_key)
            data[user_key][month_year_key] = format_currency(amount)
          else
            data[user_key]['user_total'] = format_currency(currency_as_amount(data[user_key]['user_total']) + amount)
          end
        end
      end
    end
    data
  end

  def self.all_users_outflow(from_date, to_date)
    from_date = Date.parse(from_date)
    to_date = Date.parse(to_date)
    data = {}
    lower_date = from_date
    (from_date..to_date).each do |d|
      if d > from_date
        if d == d.end_of_month or d == to_date
          days_in_month = [d - lower_date + 1, Rails.configuration.max_work_days_per_month].min
          lower_date = Date.parse((d + 1).year.to_s + '-' + (d + 1).month.to_s + '-' + '1'.to_s)
        else
          next
        end
      end
      month_year_key = AdminUsersAudit.month_year(d)
      AdminUsersAudit.all_users(d).each do |aua|
        user_key = aua.admin_user_id
        if !data.has_key?(user_key)
          data[user_key] = {}
        else
          data[user_key]['id'] = user_key
          data[user_key]['name'] = aua.name
          data[user_key]['business_unit'] = aua.business_unit.name
          data[user_key]['date_of_joining'] = aua.date_of_joining.to_s
          data[user_key]['date_of_leaving'] = aua.date_of_leaving.to_s
          data[user_key]['active'] = aua.active.to_s
          amount = days_in_month * aua.cost_rate * Rails.configuration.max_work_hours_per_day
          if !data[user_key].has_key?('user_total')
            data[user_key]['user_total'] = format_currency(amount)
          else
            data[user_key]['user_total'] = format_currency(currency_as_amount(data[user_key]['user_total']) + amount)
          end
          if !data[user_key].has_key?(month_year_key)
            data[user_key][month_year_key] = format_currency(amount)
          else
            data[user_key]['user_total'] = format_currency(currency_as_amount(data[user_key]['user_total']) + amount)
          end
        end
      end
    end
    data
  end

  def self.active_users_inflow(from_date, to_date)
    from_date = Date.parse(from_date)
    to_date = Date.parse(to_date)
    data = {}
    lower_date = from_date
    (from_date..to_date).each do |d|
      if d > from_date
        if d == d.end_of_month or d == to_date
          lower_date = [Date.parse(d.year.to_s + '-' + d.month.to_s + '-' + '1'.to_s), from_date].max
        else
          next
        end
      end
      month_year_key = AdminUsersAudit.month_year(d)
      AdminUsersAudit.active_users(d).each do |aua|
        user_key = aua.admin_user_id
        if !data.has_key?(user_key)
          data[user_key] = {}
        else
          data[user_key]['id'] = user_key
          data[user_key]['name'] = aua.name
          data[user_key]['business_unit'] = aua.business_unit.name
          data[user_key]['date_of_joining'] = aua.date_of_joining.to_s
          data[user_key]['date_of_leaving'] = aua.date_of_leaving.to_s
          data[user_key]['active'] = aua.active.to_s
          amount = aua.bill_rate * AssignedResource.assigned_hours(user_key, lower_date, d)
          if !data[user_key].has_key?('user_total')
            data[user_key]['user_total'] = format_currency(amount)
          else
            data[user_key]['user_total'] = format_currency(currency_as_amount(data[user_key]['user_total']) + amount)
          end
          if !data[user_key].has_key?(month_year_key)
            data[user_key][month_year_key] = format_currency(amount)
          else
            data[user_key]['user_total'] = format_currency(currency_as_amount(data[user_key]['user_total']) + amount)
          end
        end
      end
    end
    data
  end

  def self.inactive_users_inflow(from_date, to_date)
    from_date = Date.parse(from_date)
    to_date = Date.parse(to_date)
    data = {}
    lower_date = from_date
    (from_date..to_date).each do |d|
      if d > from_date
        if d == d.end_of_month or d == to_date
          lower_date = [Date.parse(d.year.to_s + '-' + d.month.to_s + '-' + '1'.to_s), from_date].max
        else
          next
        end
      end
      month_year_key = AdminUsersAudit.month_year(d)
      AdminUsersAudit.inactive_users(d).each do |aua|
        user_key = aua.admin_user_id
        if !data.has_key?(user_key)
          data[user_key] = {}
        else
          data[user_key]['id'] = user_key
          data[user_key]['name'] = aua.name
          data[user_key]['business_unit'] = aua.business_unit.name
          data[user_key]['date_of_joining'] = aua.date_of_joining.to_s
          data[user_key]['date_of_leaving'] = aua.date_of_leaving.to_s
          data[user_key]['active'] = aua.active.to_s
          amount = aua.bill_rate * AssignedResource.assigned_hours(user_key, lower_date, d)
          if !data[user_key].has_key?('user_total')
            data[user_key]['user_total'] = format_currency(amount)
          else
            data[user_key]['user_total'] = format_currency(currency_as_amount(data[user_key]['user_total']) + amount)
          end
          if !data[user_key].has_key?(month_year_key)
            data[user_key][month_year_key] = format_currency(amount)
          else
            data[user_key]['user_total'] = format_currency(currency_as_amount(data[user_key]['user_total']) + amount)
          end
        end
      end
    end
    data
  end

  def self.all_users_inflow(from_date, to_date)
    from_date = Date.parse(from_date)
    to_date = Date.parse(to_date)
    data = {}
    lower_date = from_date
    (from_date..to_date).each do |d|
      if d > from_date
        if d == d.end_of_month or d == to_date
          lower_date = [Date.parse(d.year.to_s + '-' + d.month.to_s + '-' + '1'.to_s), from_date].max
        else
          next
        end
      end
      month_year_key = AdminUsersAudit.month_year(d)
      AdminUsersAudit.all_users(d).each do |aua|
        user_key = aua.admin_user_id
        if !data.has_key?(user_key)
          data[user_key] = {}
        else
          data[user_key]['id'] = user_key
          data[user_key]['name'] = aua.name
          data[user_key]['business_unit'] = aua.business_unit.name
          data[user_key]['date_of_joining'] = aua.date_of_joining.to_s
          data[user_key]['date_of_leaving'] = aua.date_of_leaving.to_s
          data[user_key]['active'] = aua.active.to_s
          amount = aua.bill_rate * AssignedResource.assigned_hours(user_key, lower_date, d)
          if !data[user_key].has_key?('user_total')
            data[user_key]['user_total'] = format_currency(amount)
          else
            data[user_key]['user_total'] = format_currency(currency_as_amount(data[user_key]['user_total']) + amount)
          end
          if !data[user_key].has_key?(month_year_key)
            data[user_key][month_year_key] = format_currency(amount)
          else
            data[user_key]['user_total'] = format_currency(currency_as_amount(data[user_key]['user_total']) + amount)
          end
        end
      end
    end
    data
  end

  def self.active_users_netflow(from_date, to_date)
    data = {}
    outflow_data = AdminUsersAudit.active_users_outflow(from_date, to_date)
    inflow_data = AdminUsersAudit.active_users_inflow(from_date, to_date)
    inflow_data.keys.each do |x|
      inflow_data[x].keys.each do |y|
        if y == 'user_total' or y[y.length - 5, y.length] == 'AMOUNT'
          inflow_data[x][y] = format_currency(currency_as_amount(inflow_data[x][y]) - currency_as_amount(outflow_data[x][y]))
        end
      end
    end
    data = inflow_data
    data
  end

  def self.inactive_users_netflow(from_date, to_date)
    data = {}
    outflow_data = AdminUsersAudit.inactive_users_outflow(from_date, to_date)
    inflow_data = AdminUsersAudit.inactive_users_inflow(from_date, to_date)
    inflow_data.keys.each do |x|
      inflow_data[x].keys.each do |y|
        if y == 'user_total' or y[y.length - 5, y.length] == 'AMOUNT'
          inflow_data[x][y] = format_currency(currency_as_amount(inflow_data[x][y]) - currency_as_amount(outflow_data[x][y]))
        end
      end
    end
    data = inflow_data
    data
  end

  def self.all_users_netflow(from_date, to_date)
    data = {}
    outflow_data = AdminUsersAudit.all_users_outflow(from_date, to_date)
    inflow_data = AdminUsersAudit.all_users_inflow(from_date, to_date)
    inflow_data.keys.each do |x|
      inflow_data[x].keys.each do |y|
        if y == 'user_total' or y[y.length - 5, y.length] == 'AMOUNT'
          inflow_data[x][y] = format_currency(currency_as_amount(inflow_data[x][y]) - currency_as_amount(outflow_data[x][y]))
        end
      end
    end
    data = inflow_data
    data
  end

  private

  def self.month_year(as_on)
    as_on = (as_on.nil?) ? Date.today : Date.parse(as_on.to_s)
    as_on.strftime('%B').upcase.slice(0, 3) + '-' + as_on.year.to_s + '-' + 'AMOUNT'
  end
end