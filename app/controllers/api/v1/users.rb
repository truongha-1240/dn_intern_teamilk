module API
  module V1
    class Users < Grape::API
      include API::V1::Defaults

      before do
        authenticate_user!
      end

      resource :users do
        desc "Return all users"
        get "", root: :users do
          User.all
        end

        desc "Return a user"
        params do
          requires :id, desc: "ID of the user"
        end
        get ":id", root: :users do
          User.find_by id: params[:id]
        end
      end
    end
  end
end
