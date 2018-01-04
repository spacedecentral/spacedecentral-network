class UserCareersController < ApplicationController
  before_action :set_user_career, only: [:show, :edit, :update, :destroy]

  skip_before_filter :set_messages
  skip_before_filter :set_notifications
  skip_before_filter :set_global_user

  # GET /user_careers
  # GET /user_careers.json
  def index
    @user_careers = UserCareer.all
    @user = current_user

  end

  # GET /user_careers/1
  # GET /user_careers/1.json
  def show
  end

  # GET /user_careers/new
  def new
    @user_career = UserCareer.new
  end

  # GET /user_careers/1/edit
  def edit
  end

  # POST /user_careers
  # POST /user_careers.json
  def create
    @user_career = UserCareer.new(user_career_params)

    @user_careers = UserCareer.where(:user_id=>user_career_params['user_id'])
    
    respond_to do |format|
      if @user_career.save
        format.html { redirect_to @user_career, notice: 'User career was successfully created.' }
        format.json { render :show, status: :created, location: @user_career }
        format.js   { render :layout => false }
      else
        format.html { render :new }
        format.json { render json: @user_career.errors, status: :unprocessable_entity }
        format.js   { render :layout => false, status: 500 }
      end
    end
  end

  # PATCH/PUT /user_careers/1
  # PATCH/PUT /user_careers/1.json
  def update
    respond_to do |format|
      if @user_career.update(user_career_params)
        format.html { redirect_to @user_career, notice: 'User career was successfully updated.' }
        format.json { render :show, status: :ok, location: @user_career }
      else
        format.html { render :edit }
        format.json { render json: @user_career.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /user_careers/1
  # DELETE /user_careers/1.json
  def destroy
    @user_career.destroy
    respond_to do |format|
      format.html { redirect_to user_careers_url, notice: 'User career was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user_career
      @user_career = UserCareer.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_career_params
      params.require(:user_career).permit(:position, :company, :from, :to)
    end
end
