class MissionUserRolesController < ApplicationController
  before_action :set_mission_user_role, only: [:show, :edit, :update, :destroy, :accept_membership]
  before_action :set_all_mission_user_roles, only: [:index, :update, :destroy, :accept_membership, :create]
  
  # GET /mission_user_roles
  # GET /mission_user_roles.json
  def index
    userrole = @mission_user_roles.find_by_user_id(current_user.id)
    if current_user&.is_admin_user? || userrole&.is_coordinator_or_greater?
      @mission = Mission.find_by_slug(params[:mission_id])
      @mission_user_roles_pending = @mission_user_roles.where(:pending=>true).count
    else
      redirect_to "/missions/"+params[:mission_id]
    end
  end

  # GET /mission_user_roles/1
  # GET /mission_user_roles/1.json
  def show
  end

  # GET /mission_user_roles/new
  def new
    @mission_user_role = MissionUserRole.new
    @mission = Hash.new
    @mission = Mission.find(params["mission_id"])
  end

  # GET /mission_user_roles/1/edit
  def edit
  end

  def accept_membership
    @mission_user_role.pending = false
    @mission = Hash.new
    mission_user_role_save = @mission_user_role.save
    if mission_user_role_save && !params["mission_id"].nil?
      @mission = Mission.where(:slug=>params["mission_id"]).first
      @mission_user_roles_pending = @mission_user_roles.where(:pending=>true).count
    end
    respond_to do |format|
      if mission_user_role_save
        format.html { redirect_to @mission_user_role, notice: 'Mission user role was successfully updated.' }
        format.json { render :show, status: :ok, location: @mission_user_role }
        format.js   { render :layout => false }
      else
        format.html { render :edit }
        format.json { render json: @mission_user_role.errors, status: :unprocessable_entity }
        format.js   { render :layout => false, status: 500 }
      end
    end
  end

  def join
    mission_user_role_params = Hash.new
    mission_user_role_params["mission_id"] = params["id"]
    mission_user_role_params["user_id"] = current_user.id
    mission_user_role_params["pending"] = true
    mission_user_role_params["role"] = 5
    mission_user_role_params["availability"] = params["availability"]
    mission_user_role_params["contribute"] = params["contribute"]
    @mission_user_role = MissionUserRole.new(mission_user_role_params)

    mission_user_role_save = @mission_user_role.save

    respond_to do |format|
      if mission_user_role_save
        format.html { redirect_to @mission_user_role, notice: 'Mission user role was successfully created.' }
        format.json { render :show, status: :created, location: @mission_user_role }
        format.js   { render :layout => false }
      else
        format.html { render :new }
        format.json { render json: @mission_user_role.errors, status: :unprocessable_entity }
        format.js   { render :layout => false, status: 500 }
      end
    end
  end

  # POST /mission_user_roles
  # POST /mission_user_roles.json
  def create
    mission_user_role_extra_params = Hash.new
    mission_user_role_extra_params["user_id"] = current_user.id
    if mission_user_role_params["role"] == 1
      mission_user_role_extra_params["pending"] = false
      # mission_user_role_extra_params["role"] = 1
    else
      mission_user_role_extra_params["pending"] = true
      # mission_user_role_extra_params["role"] = 5
    end
    @mission_user_role = MissionUserRole.new(mission_user_role_params.merge(mission_user_role_extra_params))

    respond_to do |format|
      if @mission_user_role.save
        format.html { redirect_to @mission_user_role, notice: 'Mission user role was successfully created.' }
        format.json { render :show, status: :created, location: @mission_user_role }
        format.js   { render :layout => false }
      else
        format.html { render :new }
        format.json { render json: @mission_user_role.errors, status: :unprocessable_entity }
        format.js   { render :layout => false, status: 500 }
      end
    end
  end

  # PATCH/PUT /mission_user_roles/1
  # PATCH/PUT /mission_user_roles/1.json
  def update
    @mission = Hash.new
    mission_user_role_params = {:role=>params["role"],:pending=>params["pending"] || @mission_user_role.pending}
    mission_user_role_save = @mission_user_role.update(mission_user_role_params)
    if mission_user_role_save && !params["mission_id"].nil?
      @mission = Mission.where(:slug=>params["mission_id"]).first
      @mission_user_roles_pending = @mission_user_roles.where(:pending=>true).count
    end
    respond_to do |format|
      if mission_user_role_save
        format.html { redirect_to mission_path(@mission) + '#mission_crews', notice: "#{@mission_user_role.user.name} role changed" }
        format.json { render :show, status: :ok, location: @mission_user_role }
        format.js   { render :layout => false }
      else
        format.html { render :edit }
        format.json { render json: @mission_user_role.errors, status: :unprocessable_entity }
        format.js   { render :layout => false, status: 500 }
      end
    end
  end

  # DELETE /mission_user_roles/1
  # DELETE /mission_user_roles/1.json
  def destroy
    @mission_user_role.destroy
    if !params["mission_id"].nil?
      @mission = Mission.where(:slug=>params["mission_id"]).first
      @mission_user_roles_pending = @mission_user_roles.where(:pending=>true).count
    end
    respond_to do |format|
      format.html { redirect_to mission_path(@mission) + '#mission_crews', notice: 'Mission user role was successfully destroyed.' }
      format.js   {
        flash[:notice] = (current_user == @mission_user_role.user ? "You have left the mission to #{@mission.name}" : "#{@mission_user_role.user.name} is removed from mission to #{@mission.name}")
        render layout: false
      }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_mission_user_role
      @mission_user_role = MissionUserRole.find(params[:id])
    end

    def set_all_mission_user_roles
      # select_clause = "DISTINCT mission_user_roles.*"
      # from_clause = "mission_user_roles as mission_user_roles, mission_user_roles as admin_roles"
      # where_clause = "mission_user_roles.mission_id = admin_roles.mission_id "
      # where_clause += " AND admin_roles.mission_id="+params[:mission_id].to_s
      # where_clause += " AND mission_user_roles.pending = 1 AND mission_user_roles.role<6 "
      # where_clause += " AND admin_roles.role=1 AND mission_user_roles.user_id<>"+current_user.id.to_s
      # @mission_user_roles = MissionUserRole.select(select_clause).where(where_clause).from(from_clause).all
      @mission_user_roles = MissionUserRole.where(:mission_id=>params["missionid"])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def mission_user_role_params
      params.permit(:user_id, :mission_id, :pending, :role, :availability, :contribute, :id)
    end
end
