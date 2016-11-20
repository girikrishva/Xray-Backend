ActiveAdmin.register_page I18n.t('menu.error') do
  menu false

  action_item only: :index do |resource|
    if params.has_key?(:back_path)
      link_to I18n.t('label.back'), params[:back_path].to_s
    else
      link_to I18n.t('label.back'), :back
    end
  end

  content title: proc { I18n.t('menu.error') } do
    div class: "blank_slate_container", id: "error_default_message" do
      span class: "blank_slate" do
      end
    end
  end
end