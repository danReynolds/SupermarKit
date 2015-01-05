class GroceriesController < ApplicationController
  extend HappyPath
  follow_happy_paths
  load_and_authorize_resource :user_group
  load_and_authorize_resource :grocery, through: :user_group, shallow: true

	def index
    respond_to do |format|
      format.json do
        groceries = @groceries.map do |grocery|
          [
            grocery.id,
            "<a href='/groceries/#{grocery.id}'>#{grocery.name}</a>".html_safe,
            grocery.description,
            grocery.items.count,
            grocery.total.to_money.format,
            grocery.finished? ? '<i class="fa fa-check"></i>'.html_safe : ''
          ]
        end
        render json: { data: groceries }
      end
    end
	end
	
	def show
	end

	def new
  end

  def create
    if @grocery.save
      redirect_to @grocery
    else
      render action: :new
    end
	end

	def edit
	end

	def update
	end

  def toggle_finish
    @grocery.finished_at = @grocery.finished? ? nil : DateTime.now
    if @grocery.save
      redirect_to @grocery.user_group, notice: 'Grocery list updated, happy shopping.'
    else
      render :show, notice: 'Could not modify grocery.'
    end
  end

private

  def grocery_params
    params.require(:grocery).permit(:name, :description)
  end
end
