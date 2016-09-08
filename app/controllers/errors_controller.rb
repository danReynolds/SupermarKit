class ErrorsController < ApplicationController
  skip_before_filter :require_login
  skip_authorization_check

  before_action :report

  def show
    render "errors/#{@response}", status: @status_code
  end

private

  def report
    @exception = env['action_dispatch.exception']
    @status_code = ActionDispatch::ExceptionWrapper.new(env, @exception).status_code
    @response = ActionDispatch::ExceptionWrapper.rescue_responses[@exception.class.name]
  end
end
