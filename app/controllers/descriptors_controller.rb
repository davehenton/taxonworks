class DescriptorsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_descriptor, only: [:show, :edit, :update, :destroy, :annotations]

  # GET /descriptors
  # GET /descriptors.json
  def index
    respond_to do |format|
      format.html do
        @recent_objects = Descriptor.recent_from_project_id(sessions_current_project_id).order(updated_at: :desc).limit(10)
        render '/shared/data/all/index'
      end
      format.json {
        @descriptors = Descriptor.all.limit(20)
      }
    end
  end

  # GET /descriptors/1
  # GET /descriptors/1.json
  def show
  end

  def list
    @descriptor = Descriptor.with_project_id(sessions_current_project_id).page(params[:page])
  end

  # GET /descriptors/new
  def new
    @descriptor = Descriptor.new
  end

  # GET /descriptors/1/edit
  def edit
  end

  # POST /descriptors
  # POST /descriptors.json
  def create
    @descriptor = Descriptor.new(descriptor_params)

    respond_to do |format|
      if @descriptor.save
        format.html { redirect_to @descriptor.metamorphosize, notice: 'Descriptor was successfully created.' }
        format.json { render :show, status: :created, location: @descriptor.metamorphosize }
      else
        format.html { render :new }
        format.json { render json: @descriptor.metamorphosize.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /descriptors/1
  # PATCH/PUT /descriptors/1.json
  def update
    respond_to do |format|
      if @descriptor.update(descriptor_params)
        format.html { redirect_to @descriptor.metamorphosize, notice: 'Descriptor was successfully updated.' }
        format.json { render :show, status: :ok, location: @descriptor.metamorphosize }
      else
        format.html { render :edit }
        format.json { render json: @descriptor.metamorphosize.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /descriptors/1
  # DELETE /descriptors/1.json
  def destroy
    @descriptor.destroy
    respond_to do |format|
      format.html { redirect_to descriptors_url, notice: 'Descriptor was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def autocomplete
    @descriptors = Queries::DescriptorAutocompleteQuery.new(params.require(:term), project_id: sessions_current_project_id).all

    data = @descriptors.collect do |t|
      {id:              t.id,
       label:           t.name,
       gid:             t.to_global_id.to_s,
       response_values: {
         params[:method] => t.id
       },
       label_html:      t.name
      }
    end
    render json: data
  end

  def search
    if params[:id].blank?
      redirect_to descriptors_path, notice: 'You must select an item from the list with a click or tab press before clicking show.'
    else
      redirect_to descriptor_path(params[:id])
    end
  end

  # GET /annotations
  def annotations
    @object = @descriptor
    render '/shared/data/all/annotations'
  end

  def batch_load
  end

  def preview_modify_gene_descriptor_batch_load
    if params[:file]
      @result = BatchLoad::Import::Descriptors::ModifyGeneDescriptorInterpreter.new(batch_params)
      digest_cookie(params[:file].tempfile, :modify_gene_descriptor_batch_load_descriptors_md5)
      render 'descriptors/batch_load/modify_gene_descriptor/preview'
    else
      flash[:notice] = 'No file provided!'
      redirect_to action: :batch_load
    end
  end

  def create_modify_gene_descriptor_batch_load
    if params[:file] && digested_cookie_exists?(params[:file].tempfile, :modify_gene_descriptor_batch_load_descriptors_md5)
      @result = BatchLoad::Import::Descriptors::ModifyGeneDescriptorInterpreter.new(batch_params)
      if @result.create
        flash[:notice] = "Successfully proccessed file, #{@result.total_records_created} Gene Descriptors were modified."
        render 'descriptors/batch_load/modify_gene_descriptor/create' and return
      else
        flash[:alert] = 'Batch import failed.'
      end
    else
      flash[:alert] = 'File to batch upload must be supplied.'
    end
    render :batch_load
  end

private

  def set_descriptor
    @descriptor = Descriptor.find(params[:id])
  end

  def descriptor_params
    params.require(:descriptor).permit(:name, :short_name, :type)
  end

  def batch_params
    params.permit(:file).merge(user_id: sessions_current_user_id, project_id: sessions_current_project_id).to_h.symbolize_keys
  end
end
