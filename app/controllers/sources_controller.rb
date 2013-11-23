#class SourcesController < ApplicationController
#  before_filter :authenticate_user!
#
#  # GET /sources
#  # GET /sources.json
#  def index
#    source_scope = Source.current
#    @sources = source_scope.search_by_terms(parse_search_terms(params[:search])).set_order(params[:order], "id asc").page_per(params)
#
#    respond_to do |format|
#      format.html # index.html.erb
#      format.js
#      format.json { render json: @sources }
#    end
#  end
#
#  # GET /sources/1
#  # GET /sources/1.json
#  def show
#    @source = Source.current.find(params[:id])
#
#    respond_to do |format|
#      format.html # show.html.erb
#      format.json { render json: @source }
#    end
#  end
#
#  # GET /sources/new
#  # GET /sources/new.json
#  def new
#    @source = Source.new
#
#    respond_to do |format|
#      format.html # new.html.erb
#      format.json { render json: @source }
#    end
#  end
#
#  # GET /sources/1/edit
#  def edit
#    @source = Source.current.find(params[:id])
#  end
#
#  # POST /sources
#  # POST /sources.json
#  def create
#    @source = Source.logged_new(post_params, current_user)
#
#    respond_to do |format|
#      if @source.save
#        format.html { redirect_to @source, notice: 'Source was successfully created.' }
#        format.json { render json: @source, status: :created, location: @source }
#      else
#        format.html { render action: "new" }
#        format.json { render json: @source.errors, status: :unprocessable_entity }
#      end
#    end
#  end
#
#  # PUT /sources/1
#  # PUT /sources/1.json
#  def update
#    @source = Source.current.find(params[:id])
#
#    respond_to do |format|
#      if @source.logged_update_attributes(post_params, current_user)
#        format.html { redirect_to @source, notice: 'Source was successfully updated.' }
#        format.json { head :no_content }
#      else
#        format.html { render action: "edit" }
#        format.json { render json: @source.errors, status: :unprocessable_entity }
#      end
#    end
#  end
#
#  # DELETE /sources/1
#  # DELETE /sources/1.json
#  def destroy
#    @source = Source.current.find(params[:id])
#    @source.destroy
#
#    respond_to do |format|
#      format.html { redirect_to sources_url }
#      format.json { head :no_content }
#    end
#  end
#
#  private
#
#  def parse_date(date_string)
#    date_string.to_s.split('/').last.size == 2 ? Date.strptime(date_string, "%m/%d/%y") : Date.strptime(date_string, "%m/%d/%Y") rescue ""
#  end
#
#  def post_params
#    params[:source] ||= {}
#
#    [].each do |date|
#      params[:source][date] = parse_date(params[:source][date])
#    end
#
#    params[:source].slice(
#      :source_type_id, :user_id, :location, :description, :notes
#    )
#  end
#end
