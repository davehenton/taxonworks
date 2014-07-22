require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

describe IdentifiersController do
  before(:each) {
    sign_in 
  }

  # This should return the minimal set of attributes required to create a valid
  # Georeference. As you add validations to Georeference be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) { 
    strip_housekeeping_attributes( FactoryGirl.build(:valid_identifier).attributes )
  } 

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # IdentifiersController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET index" do
    it "assigns all identifiers as @identifiers" do
      identifier = Identifier.create! valid_attributes
      get :index, {}, valid_session
      assigns(:identifiers).should eq([identifier])
    end
  end

  describe "GET show" do
    it "assigns the requested identifier as @identifier" do
      identifier = Identifier.create! valid_attributes
      get :show, {:id => identifier.to_param}, valid_session
      assigns(:identifier).should eq(identifier)
    end
  end

  describe "GET new" do
    it "assigns a new identifier as @identifier" do
      get :new, {}, valid_session
      assigns(:identifier).should be_a_new(Identifier)
    end
  end

  describe "GET edit" do
    it "assigns the requested identifier as @identifier" do
      identifier = Identifier.create! valid_attributes
      get :edit, {:id => identifier.to_param}, valid_session
      assigns(:identifier).should eq(identifier)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Identifier" do
        expect {
          post :create, {:identifier => valid_attributes}, valid_session
        }.to change(Identifier, :count).by(1)
      end

      it "assigns a newly created identifier as @identifier" do
        post :create, {:identifier => valid_attributes}, valid_session
        assigns(:identifier).should be_a(Identifier)
        assigns(:identifier).should be_persisted
      end

      it "redirects to the created identifier" do
        post :create, {:identifier => valid_attributes}, valid_session
        response.should redirect_to(Identifier.last.becomes(Identifier))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved identifier as @identifier" do
        # Trigger the behavior that occurs when invalid params are submitted
        Identifier.any_instance.stub(:save).and_return(false)
        post :create, {:identifier => { "identified_object_id" => "invalid value" }}, valid_session
        assigns(:identifier).should be_a_new(Identifier)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Identifier.any_instance.stub(:save).and_return(false)
        post :create, {:identifier => { "identified_object_id" => "invalid value" }}, valid_session
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested identifier" do
        identifier = Identifier.create! valid_attributes
        # Assuming there are no other identifiers in the database, this
        # specifies that the Identifier created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        Identifier.any_instance.should_receive(:update).with({ "identified_object_id" => "1" })
        put :update, {:id => identifier.to_param, :identifier => { "identified_object_id" => "1" }}, valid_session
      end

      it "assigns the requested identifier as @identifier" do
        identifier = Identifier.create! valid_attributes
        put :update, {:id => identifier.to_param, :identifier => valid_attributes}, valid_session
        assigns(:identifier).should eq(identifier)
      end

      it "redirects to the identifier" do
        identifier = Identifier.create! valid_attributes
        put :update, {:id => identifier.to_param, :identifier => valid_attributes}, valid_session
        response.should redirect_to(identifier.becomes(Identifier))
      end
    end

    describe "with invalid params" do
      it "assigns the identifier as @identifier" do
        identifier = Identifier.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Identifier.any_instance.stub(:save).and_return(false)
        put :update, {:id => identifier.to_param, :identifier => { "identified_object_id" => "invalid value" }}, valid_session
        assigns(:identifier).should eq(identifier)
      end

      it "re-renders the 'edit' template" do
        identifier = Identifier.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Identifier.any_instance.stub(:save).and_return(false)
        put :update, {:id => identifier.to_param, :identifier => { "identified_object_id" => "invalid value" }}, valid_session
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested identifier" do
      identifier = Identifier.create! valid_attributes
      expect {
        delete :destroy, {:id => identifier.to_param}, valid_session
      }.to change(Identifier, :count).by(-1)
    end

    it "redirects to the identifiers list" do
      identifier = Identifier.create! valid_attributes
      delete :destroy, {:id => identifier.to_param}, valid_session
      response.should redirect_to(identifiers_url)
    end
  end

end
