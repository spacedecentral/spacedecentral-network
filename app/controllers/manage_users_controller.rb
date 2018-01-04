class ManageUsersController < ApplicationController
  before_action :authenticate_user!
  before_action :check_admin_privileges

  def index
    @users = User.all
  end

  def new_account
    @user = User.new
  end

  def create_account
    pass = ['1'..'9','a'..'z'].map(&:to_a).flatten.shuffle.take(12).join
    begin
      @user = User.new(:email=>params[:user_email],
                    :name=>params[:user_name], 
                    :password=>pass, 
                    :password_confirmation=>pass, 
                    :role=>User::DEFAULT_USER)    
      @user.skip_confirmation!
      user_save = @user.save!
      @user.send_reset_password_instructions
    rescue Exception => e
    end

    respond_to do |format|
      if user_save
        format.html { redirect_to @user, notice: 'User Account was successfully created.' }
        format.json { render :show, status: :created, location: @user }
        format.js   { render :layout => false }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
        format.js   { render :layout => false, status: 500 }
      end
    end
  end

  def resend_confirmation_instructions
    ids = params['user_ids'].split(',')
    users = User.where(:id=>ids)
    users.each do |u|
      u.send_confirmation_instructions
    end
  end

  def send_password_reset
    ids = params['user_ids'].split(',')
    users = User.where(:id=>ids)
    users.each do |u|
      u.send_reset_password_instructions
    end
  end

  def suspend_account
  end

  def activate_account
  end

  private
    def check_admin_privileges
      !current_user.nil? && current_user.is_admin_user?
    end

end
