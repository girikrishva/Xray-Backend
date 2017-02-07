ActiveAdmin.register AdminUser, as:"Organization Chart" do
  menu if: proc { is_menu_authorized? [I18n.t('role.manager')] }, label: "Organization Chart", parent: I18n.t('menu.reports'), priority: 10
 permit_params :primary_skill, :as_on, :bill_rate, :cost_rate, :comments, :admin_user_id, :skill_id, :skill_name, :is_latest
  config.sort_order = 'admin_users.name_asc_and_skills.name_asc_and_as_on_desc'

  config.clear_action_items!
config.batch_actions = false

 before_filter :skip_sidebar!
  index  :download_links => false do
    render partial: "organization_chart"
     div class:"popup","data-popup": "popup-1" do
      div class:"popup-inner",style:"overflow : auto;" do
        span class:"ajax_content" do 
        end
          a class:"popup-close","data-popup-close":"popup-1","href":"#" do
            "Close"
          end
      end
  end
  end
    controller do
    before_filter do |c|
      c.send(:is_resource_authorized?, [I18n.t('role.executive')])
    end

    def get_users
      @users = AdminUser.where(manager_id:params["id"])
      a = []
      @users.each do |user|
        count =  AdminUser.where(:manager_id =>user.id).count()
        user_name = count > 0 ? "#{user.name} (#{count})" : user.name 
        a << {"Name": user_name,id:user.id,"ChildrenUrl":"/admin/get_team?id=#{user.id}","HasChildren": count > 0 ? true : false}
      end
      render json: a
    end
    def scoped_collection
      ids = Resource.latest(Date.today).collect(&:id)
      Resource.includes([:admin_user, :skill]).where(id:ids)
    end
  end
end
