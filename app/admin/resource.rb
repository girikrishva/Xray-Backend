ActiveAdmin.register Resource do
  menu if: proc { is_menu_authorized? ["Executive"] }, label: 'Resources', parent: 'Operations', priority: 10

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
    link_to "New", new_admin_resource_path
  end

  action_item only: :show do |resource|
    link_to "Back", admin_resources_path
  end

  index do
#   index as: :grouped_table, group_by_attribute: :skill_name do
    selectable_column
    column :id
    column 'User', :admin_user, sortable: 'admin_users.name' do |resource|
      resource.admin_user.name
    end
    column :skill, sortable: 'skills.name' do |resource|
      resource.skill.name
    end
    column :as_on
    column :is_latest
    column :bill_rate, :sortable => 'bill_rate' do |element|
      div :style => "text-align: right;" do
        number_with_precision element.bill_rate, precision: 2, delimiter: ','
      end
    end
    column :cost_rate, :sortable => 'cost_rate' do |element|
      div :style => "text-align: right;" do
        number_with_precision element.cost_rate, precision: 2, delimiter: ','
      end
    end
    column :primary_skill
    column :comments
    actions defaults: true, dropdown: true
  end

  filter :admin_user, label: 'User'
  filter :skill, collection:
                   proc { Lookup.lookups_for_name('Skills') }
  filter :as_on
  filter :is_latest
  filter :bill_rate
  filter :cost_rate
  filter :primary_skill
  filter :comments

  show do |r|
    attributes_table_for r do
      row :id
      row 'User', :admin_user do
        r.admin_user.name
      end
      row :skill do
        r.skill.name
      end
      row :as_on
      row :is_latest
      row :bill_rate do
        number_with_precision r.bill_rate, precision: 2, delimiter: ','
      end
      row :cost_rate do
        number_with_precision r.cost_rate, precision: 2, delimiter: ','
      end
      row :primary_skill
      row :comments
    end
  end

  controller do
    before_filter do |c|
      c.send(:is_resource_authorized?, ["Executive"])
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
  end

  form do |f|
    if f.object.as_on.blank?
      f.object.as_on = Date.today
    end
    f.inputs do
      if f.object.admin_user_id.blank?
        f.input :admin_user, label: 'User', as: :select, collection:
                               AdminUser.all
                                   .map { |a| [a.name, a.id] }, include_blank: true
      else
        f.input :admin_user, label: 'User', input_html: {disabled: :true}
        f.input :admin_user_id, as: :hidden
      end
      if f.object.skill_id.blank?
        f.input :skill, as: :select, collection:
                          Lookup.lookups_for_name('Skills')
                              .map { |a| [a.name, a.id] }, include_blank: true
      else
        f.input :skill, input_html: {disabled: :true}
        f.input :skill_id, as: :hidden
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
      f.action(:submit, label: 'Save')
      f.cancel_link
    end
  end
end
