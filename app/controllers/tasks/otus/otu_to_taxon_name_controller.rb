class Tasks::Otus::OtuToTaxonNameController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def index
    @otus = Otu.where('taxon_name_id IS NULL')
  end

  # GET
  def search
  end

  # POST
  def update
  end

end