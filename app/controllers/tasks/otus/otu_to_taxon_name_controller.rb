class Tasks::Otus::OtuToTaxonNameController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def index
    @otus = Otu.where("taxon_name_id IS NULL and project_id = #{sessions_current_project_id}").page(params[:page])
  end

  # GET
  def search
  end

  # POST
  def update
    otu_params = {id: params['otu_id'], taxon_name_id: params['taxon_name_id']}
    otu_id = params['otu_id']
    @otu = Otu.find(otu_id)
    unless (otu_params[:taxon_name_id].blank?)
      if @otu.update(otu_params)
        flash['notice'] = "Updated OTU #{@otu.name}, id: #{@otu.id}"
      else
        flash['notice'] = "OTU #{@otu.name}, id: #{@otu.id} NOT updated"
      end
    else
      # otu_params = {id: params['otu_id'], taxon_name_id: params['search_id']}
      otu_params[:taxon_name_id] = params['search_id']
      unless (otu_params[:taxon_name_id].blank?)
        if @otu.update(otu_params) # {id: otu_id, taxon_name_id: params['search_id']})
          flash['notice'] = "Updated OTU #{@otu.name}, id: #{@otu.id}"
        else
          flash['notice'] = "OTU #{@otu.name}, id: #{@otu.id} NOT updated"
        end
      end
    end

    data = {otu_id: otu_id}
    render :json => data
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

  def otu_params_not
    params.permit(:taxon_name_id)
  end

end