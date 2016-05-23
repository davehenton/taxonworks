class Tasks::Gis::LocalityController < ApplicationController
  include TaskControllerConfiguration

  def nearby
    if params[:id]
      @collecting_event = CollectingEvent.where(project_id: sessions_current_project_id).find(params[:id])
      @nearby_distance   = Utilities::Geo.nearby_from_params(params)
      @collecting_events = @collecting_event.collecting_events_within_radius_of(@nearby_distance).where(project_id: sessions_current_project_id).limit(100).order(:verbatim_locality)
    else
      @collecting_event = CollectingEvent.new()
      @collecting_events = []
      @nearby_distance = 5000
    end
 end

  def within
    @geographic_item   = GeographicItem.find(params[:id])
    @collecting_events = CollectingEvent.where(project_id: sessions_current_project_id).contained_within(@geographic_item)
  end

  # @return [Scope] Preload an  empty set of collecting events
  def new_list
    @collecting_events = CollectingEvent.where('false')
  end

  # use the params[:geographic_area_id] to locate the area, use that to find a geographic
  def list
    @geographic_area = GeographicArea.find(params[:geographic_area_id])
    case params[:commit]
      when 'Show'
        if @geographic_area.has_shape?
          @collecting_events = CollectingEvent.contained_within(@geographic_area.default_geographic_item)
                                 .order(:verbatim_locality)
                                 .select(:id)
        else
          @collecting_events = CollectingEvent.where('false')
        end
      # gather_list_data(@geographic_item)
      else
    end
  end

  protected
  
  def gather_list_data(geographic_area)
    if @geographic_area.has_shape?
      @geographic_item = @geographic_area.default_geographic_item
    else
      @geographic_item = nil
    end
  end

end
