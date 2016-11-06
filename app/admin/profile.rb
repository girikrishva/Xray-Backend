ActiveAdmin.register_page 'Profile' do
  menu label: 'Manage Profile', parent: 'Security', priority: 20

  controller do
    before_filter do
      redirect_to edit_admin_admin_user_path(id: current_admin_user.id)
    end
  end
end
