ActiveAdmin.register Account do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  form do |f|
    f.inputs do
      f.input :admin_user, :member_label => :email
      f.input :balance
    end
    f.actions
  end
  actions :all, except: [:edit, :update]
  permit_params :balance, :admin_user_id
  #
  # or
  #
  # permit_params do
  #   permitted = [:balance, :admin_user_id]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

end
