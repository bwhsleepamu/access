class SourcesController < ApplicationController
  before_filter :authenticate_user!
  before_action :set_source, only: [:show, :edit, :update, :destroy]

  # GET /sources
  # GET /sources.json
  def index
    sources_scope = Source.current
    @sources = sources_scope.search_by_terms(parse_search_terms(params[:search])).set_order(params[:order], "location asc").page_per(params)
  end

  # GET /sources/1
  # GET /sources/1.json
  def show
  end

  # GET /sources/new
  # GET /sources/new.json
  def new
    @source = Source.new
  end

  # GET /sources/1/edit
  def edit
  end

  # POST /sources
  # POST /sources.json
  def create
    @source = Source.logged_new(source_params, current_user)
    @source.user_id = current_user.id

    respond_to do |format|
      if @source.save
        format.html { redirect_to @source, notice: 'Source was successfully created.' }
        format.json { render json: @source, status: :created, location: @source }
      else
        format.html { render action: "new" }
        format.json { render json: @source.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /sources/1
  # PUT /sources/1.json
  def update
    @source = Source.current.find(params[:id])

    respond_to do |format|
      if @source.logged_update(source_params, current_user)
        format.html { redirect_to @source, notice: 'Source was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @source.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sources/1
  # DELETE /sources/1.json
  def destroy
    @source.destroy

    respond_to do |format|
      format.html { redirect_to sources_url }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_source
    @source = Source.current.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def source_params
    params.require(:source).permit(:location, :original_location, :description, :source_type_id, :notes, :parent_source_id, :child_source_ids)
  end

  def parse_date(date_string)
    date_string.to_s.split('/').last.size == 2 ? Date.strptime(date_string, "%m/%d/%y") : Date.strptime(date_string, "%m/%d/%Y") rescue ""
  end

end
