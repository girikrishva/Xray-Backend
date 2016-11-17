class PipelineStatus < ActiveRecord::Base
  self.primary_key = 'id'

  has_many :pipelines, class_name: 'Pipeline'
end