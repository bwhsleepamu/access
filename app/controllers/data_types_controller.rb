class DataTypesController < ApplicationController
  before_filter :authenticate_user!
  before_action :set_data_type, only: [:show, :edit, :update, :destroy]

  # GET /data_types
  # GET /data_types.json
  def index
    data_types_scope = DataType.current
    @data_types = data_types_scope.search_by_terms(parse_search_terms(params[:search])).set_order(params[:order], "name asc").page_per(params) #.page(params[:page] ? params[:page] : 1).per(params[:per_page] == "all" ? nil : params[:per_page])
  end

  # GET /data_types/1
  # GET /data_types/1.json
  def show
  end

  # GET /data_types/new
  def new
    @data_type = DataType.new
  end

  # GET /data_types/1/edit
  def edit
  end

  # POST /data_types
  # POST /data_types.json
  def create
    @data_type = DataType.logged_new(data_type_params, current_user)
    @data_type.user_id = current_user.id

    respond_to do |format|
      if @data_type.save
        format.html { redirect_to @data_type, notice: 'DataType was successfully created.' }
        format.json { render action: 'show', status: :created, location: @data_type }
      else
        format.html { render action: 'new' }
        format.json { render json: @data_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /data_types/1
  # PATCH/PUT /data_types/1.json
  def update
    respond_to do |format|
      if @data_type.logged_update(data_type_params)
        format.html { redirect_to @data_type, notice: 'DataType was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @data_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /data_types/1
  # DELETE /data_types/1.json
  def destroy
    @data_type.destroy
    respond_to do |format|
      format.html { redirect_to data_types_url }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_data_type
    @data_type = DataType.current.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def data_type_params
    params.require(:data_type).permit(:name, :storage, :range, :length, :values, :multiple)
  end
end
