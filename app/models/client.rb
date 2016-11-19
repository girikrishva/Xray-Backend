class Client < ActiveRecord::Base
  belongs_to :business_unit, class_name: 'BusinessUnit', foreign_key: :business_unit_id

  has_many :pipelines, class_name: 'Pipeline'
  has_many :pipelines_audits, class_name: 'PipelinesAudit'
  has_many :projects, class_name: 'Project'

  validates :business_unit_id, presence: true
  validates :name, presence: true

  validates_uniqueness_of :business_unit_id, scope: [:business_unit_id, :name]
  validates_uniqueness_of :name, scope: [:business_unit_id, :name]

  def business_unit_name
    BusinessUnit.find(self.business_unit_id).name
  end

  def self.ordered_lookup
    Client.all.order(:name)
  end
end