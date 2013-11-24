class SourceTypesController < ApplicationController
  before_filter :authenticate_user!
  before_action :set_source_type, only: [:show, :edit, :update, :destroy]

  # GET /source_types
  # GET /source_types.json
  def index
    source_types_scope = SourceType.current
    @source_types = source_types_scope.search_by_terms(parse_search_terms(params[:search])).set_order(params[:order], "name asc").page_per(params) #.page(params[:page] ? params[:page] : 1).per(params[:per_page] == "all" ? nil : params[:per_page])
  end

  # GET /source_types/1
  # GET /source_types/1.json
  def show
  end

  # GET /source_types/new
  def new
    @source_type = SourceType.new
  end

  # GET /source_types/1/edit
  def edit
  end

  # POST /source_types
  # POST /source_types.json
  def create
    @source_type = SourceType.logged_new(source_type_params, current_user)

    respond_to do |format|
      if @source_type.save
        format.html { redirect_to @source_type, notice: 'SourceType was successfully created.' }
        format.json { render action: 'show', status: :created, location: @source_type }
      else
        format.html { render action: 'new' }
        format.json { render json: @source_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /source_types/1
  # PATCH/PUT /source_types/1.json
  def update
    respond_to do |format|
      if @source_type.logged_update(source_type_params)
        format.html { redirect_to @source_type, notice: 'SourceType was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @source_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /source_types/1
  # DELETE /source_types/1.json
  def destroy
    @source_type.destroy
    respond_to do |format|
      format.html { redirect_to source_types_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_source_type
      @source_type = SourceType.current.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def source_type_params
      MY_LOG.info params
      params.require(:source_type).permit(:name, :description)
    end
end
