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
    myParams = params
    @otu = Otu.where({id: myParams['otu_id']})
    if !(myParams['taxon_name_id'].blank?)
      otu_params = [{id: myParams['otu_id']}, {taxon_name_id: myParams['taxon_name_id']}]
      if @otu.update(*otu_params)
        flash['notice'] = "Updated OTU #{@otu.name}, id: #{@otu.id}"
      else
        flash['notice'] = "OTU #{@otu.name}, id: #{@otu.id} NOT updated"
      end
    end
    stop_here = 1
  end

  def autocomplete # directly cloned from TaxonNamesController
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