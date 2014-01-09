class SubjectGroupsController < ApplicationController
  before_filter :authenticate_user!
  before_action :set_subject_group, only: [:show, :edit, :update, :destroy]

  # GET /subject_groups
  # GET /subject_groups.json
  def index
    subject_groups_scope = SubjectGroup.current
    @subject_groups = subject_groups_scope.search_by_terms(parse_search_terms(params[:search])).set_order(params[:order], "created_at desc").page_per(params)
  end

  # GET /subject_groups/1
  # GET /subject_groups/1.json
  def show
  end

  # GET /subject_groups/new
  # GET /subject_groups/new.json
  def new
    @subject_group = SubjectGroup.new
  end

  # GET /subject_groups/1/edit
  def edit
  end

  # POST /subject_groups
  # POST /subject_groups.json
  def create
    @subject_group = SubjectGroup.logged_new(subject_group_params, current_user)

    respond_to do |format|
      if @subject_group.save
        format.html { redirect_to @subject_group, notice: 'SubjectGroup was successfully created.' }
        format.json { render json: @subject_group, status: :created, location: @subject_group }
      else
        format.html { render action: "new" }
        format.json { render json: @subject_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /subject_groups/1
  # PUT /subject_groups/1.json
  def update
    @subject_group = SubjectGroup.current.find(params[:id])

    respond_to do |format|
      if @subject_group.logged_update(subject_group_params, current_user)
        format.html { redirect_to @subject_group, notice: 'SubjectGroup was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @subject_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /subject_groups/1
  # DELETE /subject_groups/1.json
  def destroy
    @subject_group.destroy

    respond_to do |format|
      format.html { redirect_to subject_groups_url }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_subject_group
    @subject_group = SubjectGroup.current.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def subject_group_params
    params.require(:subject_group).permit(:name, :description, subject_ids: [])
  end
end
