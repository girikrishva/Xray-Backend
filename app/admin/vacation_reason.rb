ActiveAdmin.register VacationReason do
  menu label: 'Vacation Reasons', parent: 'Masters', priority: 20

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

  permit_params :code, :description, :as_on, :paid, :days_allowed, :comments

  config.sort_order = 'as_on_desc_and_code_asc'

  config.clear_action_items!

  action_item only: :index do |resource|
    link_to "New", new_admin_vacation_reason_path
  end

  index do
    selectable_column
    column :id
    column :code
    column :description
    column :as_on
    column :paid
    column :days_allowed
    column :comments
    actions defaults: true, dropdown: true
  end

  filter :code
  filter :description
  filter :as_on
  filter :paid
  filter :days_allowed
  filter :comments

  controller do
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
    if f.object.paid.blank?
      f.object.paid = false
    end
    f.inputs do
      f.input :code
      f.input :description
      f.input :as_on, as: :datepicker
      f.input :paid
      f.input :days_allowed
      f.input :comments
    end
    f.actions
  end
end
