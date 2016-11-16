class CostAdderType < ActiveRecord::Base
  self.primary_key = 'id'

  has_many :overheads, class_name: 'Overhead'
end