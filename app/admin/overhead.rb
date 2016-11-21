ActiveAdmin.register Overhead do
  menu if: proc { is_menu_authorized? [I18n.t('role.executive')] }, label: I18n.t('menu.overheads'), parent: I18n.t('menu.masters'), priority: 20

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

  permit_params :business_unit_id, :department_id, :cost_adder_type_id, :amount_date, :amount, :comments

  config.sort_order = 'business_units.name_asc_and_departments.name_asc_and_cost_adder_types.name_asc'

  config.clear_action_items!

  action_item only: :index do |resource|
    link_to I18n.t('label.new'), new_admin_overhead_path
  end

  action_item only: :show do |resource|
    link_to I18n.t('label.back'), admin_overheads_path
  end

# index do
  index as: :grouped_table, group_by_attribute: :business_unit_name do
    selectable_column
    column :id
    # column :business_unit, sortable: 'business_units.name' do |resource|
    #   resource.business_unit.name
    # end
    column :department, sortable: 'departments.name' do |resource|
      resource.department.name
    end
    column :cost_adder_type, sortable: 'cost_adder_types.name' do |resource|
      resource.cost_adder_type.name
    end
    column :amount_date
    column :amount do |element|
      div :style => "text-align: right;" do
        number_with_precision element.amount, precision: 0, delimiter: ','
      end
    end
    column :comments
    actions defaults: true, dropdown: true
  end

  filter :business_unit, collection:
                           proc { Lookup.lookups_for_name(I18n.t('models.business_units')) }
  filter :department, collection:
                        proc { Lookup.lookups_for_name(I18n.t('models.departments')) }
  filter :cost_adder_type, collection:
                             proc { Lookup.lookups_for_name(I18n.t('models.cost_adder_types')) }
  filter :amount_date
  filter :amount
  filter :comments

  show do |r|
    attributes_table_for r do
      row :id
      row :business_unit do
        r.business_unit.name
      end
      row :department do
        r.department.name
      end
      row :cost_adder_type do
        r.cost_adder_type.name
      end
      row :amount_date
      row :amount do |element|
        div :style => "text-align: right;" do
          number_with_precision element.amount, precision: 0, delimiter: ','
        end
      end
      row :comments
    end
  end

  controller do
    before_filter do |c|
      c.send(:is_resource_authorized?, [I18n.t('role.executive')])
    end

    def scoped_collection
      Overhead.includes [:business_unit, :department, :cost_adder_type]
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
    if f.object.amount_date.blank?
      f.object.amount_date = Date.today
    end
    f.inputs do
      if f.object.business_unit_id.blank?
        f.input :business_unit, required: true, as: :select, collection:
                                  Lookup.lookups_for_name(I18n.t('models.business_units'))
                                      .map { |a| [a.name, a.id] }, include_blank: true
      else
        f.input :business_unit, required: true, input_html: {disabled: :true}
        f.input :business_unit_id, as: :hidden
      end
      if f.object.department_id.blank?
        f.input :department, required: true, as: :select, collection:
                               Lookup.lookups_for_name(I18n.t('models.departments'))
                                   .map { |a| [a.name, a.id] }, include_blank: true
      else
        f.input :department, input_html: {disabled: :true}
        f.input :department_id, required: true, as: :hidden
      end
      if f.object.cost_adder_type_id.blank?
        f.input :cost_adder_type, required: true, as: :select, collection:
                                    Lookup.lookups_for_name(I18n.t('models.cost_adder_types'))
                                        .map { |a| [a.name, a.id] }, include_blank: true
      else
        f.input :cost_adder_type, required: true, input_html: {disabled: :true}
        f.input :cost_adder_type_id, as: :hidden
      end
      if !f.object.new_record?
        f.input :amount_date, as: :datepicker, input_html: {disabled: :true}
        f.input :amount_date, as: :hidden
      else
        f.input :amount_date, as: :datepicker
      end
      if !f.object.new_record?
        f.input :amount, input_html: {readonly: true}
      else
        f.input :amount
      end
      f.input :comments
    end
    f.actions do
      f.action(:submit, label: I18n.t('label.save'))
      f.cancel_link
    end
  end
end
