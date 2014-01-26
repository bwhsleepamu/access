class EventDictionaryController < ApplicationController
  before_filter :authenticate_user!
  before_action :set_event_dictionary, only: [:show, :edit, :update, :destroy]

  # GET /event_dictionary
  # GET /event_dictionary.json
  def index
    event_dictionary_scope = EventDictionary.current
    @event_dictionary = event_dictionary_scope.search_by_terms(parse_search_terms(params[:search])).set_order(params[:order], "name asc").page_per(params) #.page(params[:page] ? params[:page] : 1).per(params[:per_page] == "all" ? nil : params[:per_page])
  end

  # GET /event_dictionary/1
  # GET /event_dictionary/1.json
  def show
  end

  # GET /event_dictionary/new
  def new
    @event_dictionary = EventDictionary.new
  end

  # GET /event_dictionary/1/edit
  def edit
  end

  # POST /event_dictionary
  # POST /event_dictionary.json
  def create
    @event_dictionary = EventDictionary.logged_new(event_dictionary_params, current_user)

    respond_to do |format|
      if @event_dictionary.save
        format.html { redirect_to @event_dictionary, notice: 'EventDictionary was successfully created.' }
        format.json { render action: 'show', status: :created, location: @event_dictionary }
      else
        format.html { render action: 'new' }
        format.json { render json: @event_dictionary.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /event_dictionary/1
  # PATCH/PUT /event_dictionary/1.json
  def update
    respond_to do |format|
      if @event_dictionary.logged_update(event_dictionary_params)
        format.html { redirect_to @event_dictionary, notice: 'EventDictionary was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @event_dictionary.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /event_dictionary/1
  # DELETE /event_dictionary/1.json
  def destroy
    @event_dictionary.destroy
    respond_to do |format|
      format.html { redirect_to event_dictionary_index_url }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_event_dictionary
    @event_dictionary = EventDictionary.current.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def event_dictionary_params
    params.require(:event_dictionary).permit(:name, :description, :paired_id, data_dictionary_ids: [], event_tag_ids: [])
  end
end

