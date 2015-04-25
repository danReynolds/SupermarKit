class GroceriesController < ApplicationController
  extend HappyPath
  follow_happy_paths
  load_and_authorize_resource :user_group
  load_and_authorize_resource :grocery, through: :user_group, shallow: true

  def index
    @active_grocery = @user_group.active_groceries.first
    @groceries = @groceries - [@active_grocery]

    respond_to do |format|
      format.json do
        groceries = @groceries.sort_by(&:created_at).map do |grocery|
          {
            id: grocery.id,
            name: grocery.name,
            description: grocery.description,
            count: grocery.items.count,
            cost: grocery.total.to_money.format,
          }
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
      current_user.default_group = @user_group unless current_user.default_group
      redirect_to @grocery
    else
      render action: :new
    end
	end

	def edit
	end

	def update
	end

  def finish_and_remove
    item_ids = params[:grocery][:item_ids].split(",").map(&:to_i)
    @grocery.item_ids -= item_ids
    @grocery.finished_at = DateTime.now

    if @grocery.save
      redirect_to @grocery.user_group
    else
      render action: :show
    end
  end

  def finish
    item_ids = params[:finish_grocery][:item_ids].split(",").map(&:to_i)
    @grocery.item_ids -= item_ids if item_ids
    @grocery.finished_at = DateTime.now
    if @grocery.save
      if params[:finish_grocery][:carry].present?
        new_grocery = Grocery.new(
          name: params[:finish_grocery][:name],
          description: params[:finish_grocery][:description]
        )
        new_grocery.user_group = @grocery.user_group
        new_grocery.item_ids = item_ids

        if new_grocery.save
          redirect_to new_grocery, notice: "Your new list has been created with the items you wanted carried over."
        else
          render action: :show
        end
      else
        redirect_to @grocery, notice: 'Great! Your list is now all finished.'
      end
    else
      render action: :show
    end
  end

  def email_group
    @grocery.user_group.users.each do |user|
      UserMailer.send_grocery_list_email(user, @grocery).deliver!
    end

    redirect_to @grocery.user_group, notice: 'All group members have been emailed the grocery list.'
  end

  def reopen
    @grocery.finished_at = @grocery.finished_at = nil

    if @grocery.save
      redirect_to @grocery, notice: 'Your grocery list has been re-opened.'
    else
      render :show, notice: 'Could not modify grocery.'
    end
  end

private

  def grocery_params
    params.require(:grocery).permit(:name, :description)
  end
end
