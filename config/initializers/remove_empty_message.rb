require 'active_admin/helpers/collection'

module ActiveAdmin
  module Views
    module Pages
      class Index < Base
        protected
        def render_blank_slate
          # for example only, you can define your own I18n structure
          # You can use active_admin_config.resource_label too if not mistaken
          blank_slate_content = I18n.t("active_admin.blank_slate.content.#{active_admin_config.plural_resource_label}")
          insert_tag(view_factory.blank_slate, blank_slate_content)
        end
      end
    end
  end
end