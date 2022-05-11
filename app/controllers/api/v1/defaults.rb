module API
  module V1
    module Defaults
      extend ActiveSupport::Concern

      included do
        prefix "api"
        version "v1", using: :path
        default_format :json
        format :json

        helpers do
          def permitted_params
            @permitted_params ||= declared(params,
               include_missing: false)
          end

          def logger
            Rails.logger
          end
        end

        # check authentice_user
        def authenticate_user!
            uid = request.headers["Uid"]
            token = request.headers["Access-Token"]
            @current_user = User.find_by(uid: uid)
            unless @current_user && @current_user.valid_token?(token)
              api_error!("You need to log in to use the app.", "failure", 401, {})
            end
          end

        # Hàm hiển thị errors message khi lỗi
        def api_error!(message, error_code, status, header)
           error!({message: message, code: error_code}, status, header)
        end

        #  # Hàm raise errors message khi lỗi
        def api_error_log(message)
            @logger ||= Logger.new(ProjectLogger.log_path("project_api"))
            @logger.info("=============#{Time.zone.now.to_s}==================\n")
            @logger.info("#{message}\n")
         end

        rescue_from ActiveRecord::RecordNotFound do |e|
          error_response(message: e.message, status: 404)
        end

        rescue_from ActiveRecord::RecordInvalid do |e|
          error_response(message: e.message, status: 422)
        end

        rescue_from Grape::Exceptions::ValidationErrors do |e|
          error_response(message: e.message, status: 400)
        end

      end
    end
  end
end
