#class SourceTypesController < ApplicationController
#  before_filter :authenticate_user!
#
#  # GET /source_types
#  # GET /source_types.json
#  def index
#    source_type_scope = SourceType.current
#    @source_types = source_type_scope.search_by_terms(parse_search_terms(params[:search])).set_order(params[:order], "name asc").page_per(params)
#
#    respond_to do |format|
#      format.html # index.html.erb
#      format.js
#      format.json { render json: @source_types }
#    end
#  end
#
#  # GET /source_types/1
#  # GET /source_types/1.json
#  def show
#    @source_type = SourceType.current.find(params[:id])
#
#    respond_to do |format|
#      format.html # show.html.erb
#      format.json { render json: @source_type }
#    end
#  end
#
#  # GET /source_types/new
#  # GET /source_types/new.json
#  def new
#    @source_type = SourceType.new
#
#    respond_to do |format|
#      format.html # new.html.erb
#      format.json { render json: @source_type }
#    end
#  end
#
#  # GET /source_types/1/edit
#  def edit
#    @source_type = SourceType.current.find(params[:id])
#  end
#
#  # POST /source_types
#  # POST /source_types.json
#  def create
#    @source_type = SourceType.logged_new(post_params)
#
#    respond_to do |format|
#      if @source_type.save
#        format.html { redirect_to @source_type, notice: 'SourceType was successfully created.' }
#        format.json { render json: @source_type, status: :created, location: @source_type }
#      else
#        format.html { render action: "new" }
#        format.json { render json: @source_type.errors, status: :unprocessable_entity }
#      end
#    end
#  end
#
#  # PUT /source_types/1
#  # PUT /source_types/1.json
#  def update
#    @source_type = SourceType.current.find(params[:id])
#
#    respond_to do |format|
#      if @source_type.logged_update_attributes(post_params)
#        format.html { redirect_to @source_type, notice: 'SourceType was successfully updated.' }
#        format.json { head :no_content }
#      else
#        format.html { render action: "edit" }
#        format.json { render json: @source_type.errors, status: :unprocessable_entity }
#      end
#    end
#  end
#
#  # DELETE /source_types/1
#  # DELETE /source_types/1.json
#  def destroy
#    @source_type = SourceType.current.find(params[:id])
#    @source_type.destroy
#
#    respond_to do |format|
#      format.html { redirect_to source_types_url }
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
#    params[:source_type] ||= {}
#
#    [].each do |date|
#      params[:source_type][date] = parse_date(params[:source_type][date])
#    end
#
#    params[:source_type].slice(
#      :name, :description
#    )
#  end
#end
