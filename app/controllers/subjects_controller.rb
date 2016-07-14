class SubjectsController < ApplicationController
  before_filter :authenticate_user!
  #before_action :set_subject, only: [:show, :edit, :update, :destroy]

  # GET /subjects
  # GET /subjects.json
  def index
    subjects_scope = Subject.current
    subjects_scope = subjects_scope.in_subject_group_by_id(params[:subject_group_ids]) if params[:subject_group_ids]
    subjects_scope = subjects_scope.in_subject_code_list(params[:subject_codes]) if params[:subject_codes]

    @subjects = subjects_scope.search_by_terms(parse_search_terms(params[:search])).set_order(params[:order], "subject_code asc").page_per(params)
  end


  # GET /projects/new
  def new
    @subject = Subject.new
  end

  # POST /projects
  def create
    @subject = Subject.new(subject_params)
    if @subject.save
      redirect_to @subject, notice: 'Subject was successfully added.'
    else
      render :new
    end
  end

  # POST /subjects
  # POST /subjects.json
  def create_list
    @subjects = Subject.create_list(subject_list_params[:subject_codes])

    respond_to do |format|

      if @subjects
        format.html { render action: 'show_list' }
        format.json { render json: @subjects }
      else
        format.html { render action: "new_list" }
        format.json { render json: @subjects.map(&:errors), status: :unprocessable_entity }
      end
    end
  end

  def new_list
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_subject
    @subject = Subject.current.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  #def subject_params
  #  params.require(:subject).permit(:location, :original_location, :description, :subject_type_id, :notes, :parent_subject_id, child_subject_ids: [])
  #end

  def subject_list_params
    MY_LOG.info params
    params.require(:subjects).permit(:subject_codes)
  end


  def subject_params
    params.require(:subject).permit(
      :name, :slug, :description, :subject_code_name, :disable_all_emails,
      :collect_email_on_surveys, :hide_values_on_pdfs,
      :randomizations_enabled, :adverse_events_enabled, :blinding_enabled,
      :handoffs_enabled, :auto_lock_sheets,
      # Uploaded Logo
      :logo, :logo_uploaded_at, :logo_cache, :remove_logo,
      # Will automatically generate a site if the project has no site
      :site_name
    )
  end
end
