module SplitController
  extend ActiveSupport::Concern

  included do
    before_action :load_and_authorize_split_resource
  end

  class_methods do
    def initialize_split_controller(res)
      define_method(:load_and_authorize_split_resource) do |resource_name: res|
        resource = resource_name.to_s.split('_').map(&:capitalize).join('')
                                .constantize.find(params["#{resource_name}_id"])
        instance_variable_set("@#{resource_name}", resource)
        authorize! "#{action_name}_#{controller_name}".to_sym, resource
      end
    end
  end
end
