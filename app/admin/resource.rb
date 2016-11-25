ActiveAdmin.register Resource do
  menu if: proc { is_menu_authorized? [I18n.t('role.executive')] }, label: I18n.t('menu.resources'), parent: I18n.t('menu.masters'), priority: 10

# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
# permit_params :list, :of, :attributes, :on, :model
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end

  permit_params :primary_skill, :as_on, :bill_rate, :cost_rate, :comments, :admin_user_id, :skill_id, :skill_name, :is_latest

  config.sort_order = 'admin_users.name_asc_and_skills.name_asc_and_as_on_desc'

  config.clear_action_items!

  action_item only: :index do |resource|
    link_to I18n.t('label.new'), new_admin_resource_path
  end

  action_item only: :show do |resource|
    link_to I18n.t('label.back'), admin_resources_path
  end

  scope :latest, default: true do |resources| resources.latest end
  scope :all

  # index do
  index as: :grouped_table, group_by_attribute: :skill_name do
    selectable_column
    column :id
    column I18n.t('label.user'), :admin_user, sortable: 'admin_users.name' do |resource|
      resource.admin_user.name
    end
    # column :skill, sortable: 'skills.name' do |resource|
    #   resource.skill.name
    # end
    column :as_on
    column I18n.t('label.latest'), (:is_latest) do |resource|
      resource.is_latest ? status_tag(:yes, :ok ) : status_tag(:no)
    end
    column :bill_rate, :sortable => 'bill_rate' do |element|
      div :style => "text-align: right;" do
        number_with_precision element.bill_rate, precision: 0, delimiter: ','
      end
    end
    column :cost_rate, :sortable => 'cost_rate' do |element|
      div :style => "text-align: right;" do
        number_with_precision element.cost_rate, precision: 0, delimiter: ','
      end
    end
    column :primary_skill
    column :comments
    actions defaults: true, dropdown: true
  end

  filter :skill, collection:
                   proc { Lookup.lookups_for_name(I18n.t('models.skills')) }
  filter :admin_user, label: 'User'
  filter :as_on
  filter :bill_rate
  filter :cost_rate
  filter :primary_skill
  filter :comments

  show do |r|
    attributes_table_for r do
      row :id
      row :skill do
        r.skill.name
      end
      row I18n.t('label.user'), :admin_user do
        r.admin_user.name
      end
      row :as_on
      row :is_latest
      row :bill_rate do
        number_with_precision r.bill_rate, precision: 0, delimiter: ','
      end
      row :cost_rate do
        number_with_precision r.cost_rate, precision: 0, delimiter: ','
      end
      row :primary_skill
      row :comments
    end
  end

  controller do
    before_filter do |c|
      c.send(:is_resource_authorized?, [I18n.t('role.executive')])
    end

    def scoped_collection
      Resource.includes [:admin_user, :skill]
    end

    def create
      super do |format|
        redirect_to collection_url and return if resource.valid?
      end
    end

    def update
      super do |format|
        redirect_to collection_url and return if resource.valid?
      end
    end

    def resources_for_staffing
      staffing_requirement_id = params[:staffing_requirement_id]
      resources = Resource.resources_for_staffing(staffing_requirement_id).first
      render json: '{"resources": "' + resources + '"}'
    end
  end

  form do |f|
    if f.object.as_on.blank?
      f.object.as_on = Date.today
    end
    f.inputs do
      if f.object.skill_id.blank?
        f.input :skill, required: true, as: :select, collection:
                          Lookup.lookups_for_name(I18n.t('models.skills'))
                              .map { |a| [a.name, a.id] }, include_blank: true
      else
        f.input :skill, required: true, input_html: {disabled: :true}
        f.input :skill_id, as: :hidden
      end
      if f.object.admin_user_id.blank?
        f.input :admin_user, required: true, label: I18n.t('label.user') + '*', as: :select, collection:
                               AdminUser.all
                                   .map { |a| [a.name, a.id] }, include_blank: true
      else
        f.input :admin_user, required: true, label: I18n.t('label.user') + '*', input_html: {disabled: :true}
        f.input :admin_user_id, as: :hidden
      end
      if !f.object.new_record?
        f.input :as_on, as: :datepicker, input_html: {disabled: :true}
        f.input :as_on, as: :hidden
      else
        f.input :as_on, as: :datepicker
      end
      if !f.object.new_record?
        f.input :bill_rate, input_html: {readonly: true}
      else
        f.input :bill_rate
      end
      if !f.object.new_record?
        f.input :cost_rate, input_html: {readonly: true}
      else
        f.input :cost_rate
      end
      if !f.object.new_record?
        f.input :primary_skill, input_html: {disabled: :true}
        f.input :primary_skill, as: :hidden
      else
        f.input :primary_skill
      end
      f.input :comments
    end
    f.actions do
      f.action(:submit, label: I18n.t('label.save'))
      f.cancel_link
    end
  end
end
