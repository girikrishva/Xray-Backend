class ClientsAudit < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :business_unit, :class_name => 'BusinessUnit', :foreign_key => :business_unit_id
  belongs_to :client, :class_name => 'Client', :foreign_key => :client_id

  validates :business_unit_id, presence: true
  validates :name, presence: true
  validates :client_id, presence: true

  default_scope { order(updated_at: :desc) }

  def business_unit_name
    self.business_unit.name
  end

  def audit_details
    I18n.t('label.updated_at') + ': ['+ datetime_as_string(self.updated_at) + '], ' + I18n.t('label.updated_by') + ': [' + self.updated_by + '], ' + I18n.t('label.ip_address') + ': [' + self.ip_address + ']' rescue nil
  end
end
