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

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_subject
    @subject = Subject.current.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  #def subject_params
  #  params.require(:subject).permit(:location, :original_location, :description, :subject_type_id, :notes, :parent_subject_id, child_subject_ids: [])
  #end
end
