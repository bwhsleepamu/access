class DataDictionaryController < ApplicationController
  before_filter :authenticate_user!
  before_action :set_data_dictionary, only: [:show, :edit, :update, :destroy]

  # GET /data_dictionary
  # GET /data_dictionary.json
  def index
    data_dictionary_scope = DataDictionary.current
    @data_dictionary = data_dictionary_scope.search_by_terms(parse_search_terms(params[:search])).set_order(params[:order], "title asc").page_per(params) #.page(params[:page] ? params[:page] : 1).per(params[:per_page] == "all" ? nil : params[:per_page])
  end

  # GET /data_dictionary/1
  # GET /data_dictionary/1.json
  def show
  end

  # GET /data_dictionary/new
  def new
    @data_dictionary = DataDictionary.new
  end

  # GET /data_dictionary/1/edit
  def edit
  end

  # POST /data_dictionary
  # POST /data_dictionary.json
  def create
    @data_dictionary = DataDictionary.logged_new(data_dictionary_params, current_user)

    respond_to do |format|
      if @data_dictionary.save
        format.html { redirect_to @data_dictionary, notice: 'DataDictionary was successfully created.' }
        format.json { render action: 'show', status: :created, location: @data_dictionary }
      else
        format.html { render action: 'new' }
        format.json { render json: @data_dictionary.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /data_dictionary/1
  # PATCH/PUT /data_dictionary/1.json
  def update
    respond_to do |format|
      if @data_dictionary.logged_update(data_dictionary_params)
        format.html { redirect_to @data_dictionary, notice: 'DataDictionary was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @data_dictionary.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /data_dictionary/1
  # DELETE /data_dictionary/1.json
  def destroy
    @data_dictionary.destroy
    respond_to do |format|
      format.html { redirect_to data_dictionary_index_url }
      format.json { head :no_content }
    end
  end


  def data_attribute_form
    data_dictionary = params[:data_dictionary_id].empty? ? DataDictionary.new : DataDictionary.find(params[:data_dictionary_id])

    data_dictionary.min_data_value = DataValue.new if data_dictionary.min_data_value.nil?
    data_dictionary.max_data_value = DataValue.new if data_dictionary.max_data_value.nil?
    data_dictionary.allowed_data_values.build #if data_dictionary.allowed_values.blank? (might be needed for blank template)

    render :partial => "data_attributes", :locals => {data_type: DataType.find(params[:data_type_id]), data_dictionary: data_dictionary }
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_data_dictionary
    @data_dictionary = DataDictionary.current.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def data_dictionary_params
    params.require(:data_dictionary).permit(:title, :description, :data_type_id, :data_unit_id, :min_value, :min_value_inclusive, :max_value, :max_value_inclusive, :multivalue, :min_length, :max_length_integer, :unit, allowed_values: [])
  end
end
