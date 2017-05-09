class Tasks::Otus::OtuToTaxonNameController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def index
    @otus = Otu.where('taxon_name_id IS NULL').page(params[:page])
  end

  # GET
  def search
  end

  # POST
  def update
  end

  def autocomplete
    @taxon_names = Queries::TaxonNameAutocompleteQuery.new(params[:term], project_id: sessions_current_project_id).all

    data = @taxon_names.collect do |t|
      str = render_to_string(partial: 'autocomplete_tag', locals: {taxon_name: t, term: params[:term]})
      {id: t.id,
       label: ApplicationController.helpers.taxon_name_autocomplete_selected_tag(t),
       response_values: {
           params[:method] => t.id
       },
       label_html: str
      }
    end

    render :json => data
  end


end