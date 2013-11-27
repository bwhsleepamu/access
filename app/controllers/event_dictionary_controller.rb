class EventDictionaryController < ApplicationController
  before_filter :authenticate_user!
  before_action :set_event_dictionary, only: [:show, :edit, :update, :destroy]

  # GET /event_dictionary
  # GET /event_dictionary.json
  def index
    event_dictionary_scope = EventDictionary.current
    @event_dictionary = event_dictionary_scope.search_by_terms(parse_search_terms(params[:search])).set_order(params[:order], "title asc").page_per(params) #.page(params[:page] ? params[:page] : 1).per(params[:per_page] == "all" ? nil : params[:per_page])
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
    @event_dictionary.user_id = current_user.id

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
    params.require(:event_dictionary).permit(:name, :description, :data_dictionary_ids, event_tag_ids: [])
  end
end










class EventDictionaryController < ApplicationController
  before_filter :authenticate_user!

  # GET /event_dictionary
  # GET /event_dictionary.json
  def index
    event_dictionary_scope = EventDictionary.current
    @event_dictionary = event_dictionary_scope.search_by_terms(parse_search_terms(params[:search])).set_order(params[:order], "name asc").page_per(params) #.page(params[:page] ? params[:page] : 1).per(params[:per_page] == "all" ? nil : params[:per_page])

    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.json { render json: @event_dictionary }
    end
  end

  # GET /event_dictionary/1
  # GET /event_dictionary/1.json
  def show
    @event_dictionary = EventDictionary.current.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @event_dictionary }
    end
  end

  # GET /event_dictionary/new
  # GET /event_dictionary/new.json
  def new
    @event_dictionary = EventDictionary.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @event_dictionary }
    end
  end

  # GET /event_dictionary/1/edit
  def edit
    @event_dictionary = EventDictionary.current.find(params[:id])
  end

  # POST /event_dictionary
  # POST /event_dictionary.json
  def create
    MY_LOG.info params
    @event_dictionary = EventDictionary.logged_new(post_params, current_user)

    respond_to do |format|
      if @event_dictionary.save
        format.html { redirect_to @event_dictionary, notice: 'EventDictionary was successfully created.' }
        format.json { render json: @event_dictionary, status: :created, location: @event_dictionary }
      else
        format.html { render action: "new" }
        format.json { render json: @event_dictionary.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /event_dictionary/1
  # PUT /event_dictionary/1.json
  def update
    @event_dictionary = EventDictionary.current.find(params[:id])

    respond_to do |format|
      if @event_dictionary.logged_update_attributes(post_params, current_user)
        format.html { redirect_to @event_dictionary, notice: 'EventDictionary was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @event_dictionary.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /event_dictionary/1
  # DELETE /event_dictionary/1.json
  def destroy
    @event_dictionary = EventDictionary.current.find(params[:id])
    @event_dictionary.destroy

    respond_to do |format|
      format.html { redirect_to event_dictionary_url }
      format.json { head :no_content }
    end
  end

  private

  def parse_date(date_string)
    date_string.to_s.split('/').last.size == 2 ? Date.strptime(date_string, "%m/%d/%y") : Date.strptime(date_string, "%m/%d/%Y") rescue ""
  end

  def post_params
    params[:event_dictionary] ||= {}

    [].each do |date|
      params[:event_dictionary][date] = parse_date(params[:event_dictionary][date])
    end

    params[:event_dictionary].slice(
      :name, :description, :data_dictionary_ids, :event_tag_ids
    )
  end
end
