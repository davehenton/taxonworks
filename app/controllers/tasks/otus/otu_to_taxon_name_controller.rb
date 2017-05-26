class Tasks::Otus::OtuToTaxonNameController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def index
    @otus = Otu.where("taxon_name_id IS NULL and project_id = #{sessions_current_project_id}").page(params[:page])
  end


end