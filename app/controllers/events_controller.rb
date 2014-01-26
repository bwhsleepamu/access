class EventsController < ApplicationController
  before_filter :authenticate_user!
  before_action :set_event, only: [:show, :edit, :update, :destroy]

  # GET /documentations
  # GET /documentations.json
  def index
    events_scope = Event.showable
    @events = events_scope.search_by_terms(parse_search_terms(params[:search])).set_order(params[:order], "title asc").page_per(params) #.page(params[:page] ? params[:page] : 1).per(params[:per_page] == "all" ? nil : params[:per_page])
  end

  # GET /events/report/name/subject_code/subject_group_name/ignore_paired
  # GET /events/report/name.json
  def report
    @report = Event.generate_report(params[:name], {subject_group_name: params[:subject_group_name], subject_code: params[:subject_code], ignore_paired: params[:ignore_paired]})
  end

  # GET /documentations/1
  # GET /documentations/1.json
  def show
  end

  # GET /documentations/new
  def new
    @event = Event.new(name: params[:name])
  end

  # GET /documentations/1/edit
  def edit
  end

  # POST /documentations
  # POST /documentations.json
  def create

    @event = Event.create(event_params)

    respond_to do |format|
      if @event.save
        format.html { redirect_to @event, notice: 'Event was successfully created.' }
        format.json { render action: 'show', status: :created, location: @documentation }
      else
        format.html { render action: 'new' }
        format.json { render json: @documentation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /documentations/1
  # PATCH/PUT /documentations/1.json
  #def update
  #  respond_to do |format|
  #    if @documentation.logged_update(documentation_params)
  #      format.html { redirect_to @documentation, notice: 'Documentation was successfully updated.' }
  #      format.json { head :no_content }
  #    else
  #      format.html { render action: 'edit' }
  #      format.json { render json: @documentation.errors, status: :unprocessable_entity }
  #    end
  #  end
  #end

  # DELETE /documentations/1
  # DELETE /documentations/1.json
  #def destroy
  #  @documentation.destroy
  #  respond_to do |format|
  #    format.html { redirect_to documentations_url }
  #    format.json { head :no_content }
  #  end
  #end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_event
    @event = Event.current.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def documentation_params
    params.require(:documentation).permit(:name, :labtime_year, :labtime_hour, :labtime_min, :labtime_sec, :realtime, :subject_id, data_list: [ :clear_all, list: [:title, :value, :notes]] )
  end
end
