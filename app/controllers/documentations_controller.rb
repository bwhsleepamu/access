#class DocumentationsController < ApplicationController
#  before_filter :authenticate_user!
#  before_action :set_documentation, only: [:show, :edit, :update, :destroy]
#
#  # GET /documentations
#  # GET /documentations.json
#  def index
#    @documentations = Documentation.all
#  end
#
#  # GET /documentations/1
#  # GET /documentations/1.json
#  def show
#  end
#
#  # GET /documentations/new
#  def new
#    @documentation = Documentation.new
#  end
#
#  # GET /documentations/1/edit
#  def edit
#  end
#
#  # POST /documentations
#  # POST /documentations.json
#  def create
#    @documentation = Documentation.logged_new(documentation_params, current_user)
#    @documentation.user_id = current_user.id
#
#    respond_to do |format|
#      if @documentation.save
#        format.html { redirect_to @documentation, notice: 'Documentation was successfully created.' }
#        format.json { render action: 'show', status: :created, location: @documentation }
#      else
#        format.html { render action: 'new' }
#        format.json { render json: @documentation.errors, status: :unprocessable_entity }
#      end
#    end
#  end
#
#  # PATCH/PUT /documentations/1
#  # PATCH/PUT /documentations/1.json
#  def update
#    respond_to do |format|
#      if @documentation.update(documentation_params)
#        format.html { redirect_to @documentation, notice: 'Documentation was successfully updated.' }
#        format.json { head :no_content }
#      else
#        format.html { render action: 'edit' }
#        format.json { render json: @documentation.errors, status: :unprocessable_entity }
#      end
#    end
#  end
#
#  # DELETE /documentations/1
#  # DELETE /documentations/1.json
#  def destroy
#    @documentation.destroy
#    respond_to do |format|
#      format.html { redirect_to documentations_url }
#      format.json { head :no_content }
#    end
#  end
#
#  private
#    # Use callbacks to share common setup or constraints between actions.
#    def set_documentation
#      @documentation = Documentation.current.find(params[:id])
#    end
#
#    # Never trust parameters from the scary internet, only allow the white list through.
#    def documentation_params
#      params.require(:documentation).permit(:title, :author, :origin_location, :description_of_procedure)
#    end
#end
