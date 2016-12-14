class ClientsAudit < ActiveRecord::Base
  belongs_to :business_unit, :class_name => 'BusinessUnit', :foreign_key => :business_unit_id
  belongs_to :client, :class_name => 'Client', :foreign_key => :client_id

  validates :business_unit_id, presence: true
  validates :name, presence: true
  validates :client_id, presence: true

  def business_unit_name
    self.business_unit.name
  end
end
