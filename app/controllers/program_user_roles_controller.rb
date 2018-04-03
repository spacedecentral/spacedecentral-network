class ProgramUserRolesController < ApplicationController
  before_action :set_program_user_role, only: [:show, :edit, :update, :destroy, :accept_membership]
  before_action :set_all_program_user_roles, only: [:index, :update, :destroy, :accept_membership, :create]
  
  # GET /program_user_roles
  # GET /program_user_roles.json
  def index
    userrole = @program_user_roles.find_by_user_id(current_user.id)
    if current_user&.is_admin_user? || userrole&.is_coordinator_or_greater?
      @program = Program.find_by_slug(params[:program_id])
      @program_user_roles_pending = @program_user_roles.where(:pending=>true).count
    else
      redirect_to "/programs/"+params[:program_id]
    end
  end

  # GET /program_user_roles/1
  # GET /program_user_roles/1.json
  def show
  end

  # GET /program_user_roles/new
  def new
    @program_user_role = ProgramUserRole.new
    @program = Hash.new
    @program = Program.find(params["program_id"])
  end

  # GET /program_user_roles/1/edit
  def edit
  end

  def accept_membership
    @program_user_role.pending = false
    @program = Hash.new
    program_user_role_save = @program_user_role.save
    if program_user_role_save && !params["program_id"].nil?
      @program = Program.where(:slug=>params["program_id"]).first
      @program_user_roles_pending = @program_user_roles.where(:pending=>true).count
    end
    respond_to do |format|
      if program_user_role_save
        format.html { redirect_to @program_user_role, notice: 'Program user role was successfully updated.' }
        format.json { render :show, status: :ok, location: @program_user_role }
        format.js   { render :layout => false }
      else
        format.html { render :edit }
        format.json { render json: @program_user_role.errors, status: :unprocessable_entity }
        format.js   { render :layout => false, status: 500 }
      end
    end
  end

  def join
    program_user_role_params = Hash.new
    program_user_role_params["program_id"] = params["id"]
    program_user_role_params["user_id"] = current_user.id
    program_user_role_params["pending"] = true
    program_user_role_params["role"] = 5
    program_user_role_params["availability"] = params["availability"]
    program_user_role_params["contribute"] = params["contribute"]
    @program_user_role = ProgramUserRole.new(program_user_role_params)

    program_user_role_save = @program_user_role.save

    respond_to do |format|
      if program_user_role_save
        format.html { redirect_to @program_user_role, notice: 'Program user role was successfully created.' }
        format.json { render :show, status: :created, location: @program_user_role }
        format.js   { render :layout => false }
      else
        format.html { render :new }
        format.json { render json: @program_user_role.errors, status: :unprocessable_entity }
        format.js   { render :layout => false, status: 500 }
      end
    end
  end

  # POST /program_user_roles
  # POST /program_user_roles.json
  def create
    program_user_role_extra_params = Hash.new
    program_user_role_extra_params["user_id"] = current_user.id
    if program_user_role_params["role"] == 1
      program_user_role_extra_params["pending"] = false
      # program_user_role_extra_params["role"] = 1
    else
      program_user_role_extra_params["pending"] = true
      # program_user_role_extra_params["role"] = 5
    end
    @program_user_role = ProgramUserRole.new(program_user_role_params.merge(program_user_role_extra_params))

    respond_to do |format|
      if @program_user_role.save
        format.html { redirect_to @program_user_role, notice: 'Program user role was successfully created.' }
        format.json { render :show, status: :created, location: @program_user_role }
        format.js   { render :layout => false }
      else
        format.html { render :new }
        format.json { render json: @program_user_role.errors, status: :unprocessable_entity }
        format.js   { render :layout => false, status: 500 }
      end
    end
  end

  # PATCH/PUT /program_user_roles/1
  # PATCH/PUT /program_user_roles/1.json
  def update
    @program = Hash.new
    program_user_role_params = {:role=>params["role"],:pending=>params["pending"] || @program_user_role.pending}
    program_user_role_save = @program_user_role.update(program_user_role_params)
    if program_user_role_save && !params["program_id"].nil?
      @program = Program.where(:slug=>params["program_id"]).first
      @program_user_roles_pending = @program_user_roles.where(:pending=>true).count
    end
    respond_to do |format|
      if program_user_role_save
        format.html { redirect_to program_path(@program) + '#program_crews', notice: "#{@program_user_role.user.name} role changed" }
        format.json { render :show, status: :ok, location: @program_user_role }
        format.js   { render :layout => false }
      else
        format.html { render :edit }
        format.json { render json: @program_user_role.errors, status: :unprocessable_entity }
        format.js   { render :layout => false, status: 500 }
      end
    end
  end

  # DELETE /program_user_roles/1
  # DELETE /program_user_roles/1.json
  def destroy
    @program_user_role.destroy
    if !params["program_id"].nil?
      @program = Program.where(:slug=>params["program_id"]).first
      @program_user_roles_pending = @program_user_roles.where(:pending=>true).count
    end
    respond_to do |format|
      format.html { redirect_to program_path(@program) + '#program_crews', notice: 'Program user role was successfully destroyed.' }
      format.js   {
        flash[:notice] = (current_user == @program_user_role.user ? "You have left the program to #{@program.name}" : "#{@program_user_role.user.name} is removed from program to #{@program.name}")
        render layout: false
      }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_program_user_role
      @program_user_role = ProgramUserRole.find(params[:id])
    end

    def set_all_program_user_roles
      # select_clause = "DISTINCT program_user_roles.*"
      # from_clause = "program_user_roles as program_user_roles, program_user_roles as admin_roles"
      # where_clause = "program_user_roles.program_id = admin_roles.program_id "
      # where_clause += " AND admin_roles.program_id="+params[:program_id].to_s
      # where_clause += " AND program_user_roles.pending = 1 AND program_user_roles.role<6 "
      # where_clause += " AND admin_roles.role=1 AND program_user_roles.user_id<>"+current_user.id.to_s
      # @program_user_roles = ProgramUserRole.select(select_clause).where(where_clause).from(from_clause).all
      @program_user_roles = ProgramUserRole.where(:program_id=>params["programid"])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def program_user_role_params
      params.permit(:user_id, :program_id, :pending, :role, :availability, :contribute, :id)
    end
end
