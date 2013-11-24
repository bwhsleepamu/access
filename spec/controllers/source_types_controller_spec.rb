require 'spec_helper'

describe SourceTypesController do
  login_user

  let(:source_type) { create(:source_type) }
  let(:valid_template) { build(:source_type) }
  let(:invalid_template) { build(:source_type, name: nil) }


  describe "GET index" do
    it "assigns all source_types as @source_types" do
      source_types = create_list(:source_type, 5)
      get :index
      source_types.each {|o| expect(assigns(:source_types)).to include(o)}
    end
  end

  describe "GET show" do
    it "assigns the requested source_type as @source_type" do
      get :show, {:id => source_type.to_param}
      expect(assigns(:source_type)).to eq(source_type)
    end
  end

  describe "GET new" do
    it "assigns a new source_type as @source_type" do
      get :new
      expect(assigns(:source_type)).to be_a_new(SourceType)
    end
  end

  describe "GET edit" do
    it "assigns the requested source_type as @source_type" do
      get :edit, {:id => source_type.to_param}
      expect(assigns(:source_type)).to eq(source_type)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new source_type, assigns it as @source_type, and redirects to show page" do
        expect {
          post :create, {:source_type => valid_template.attributes}
        }.to change(SourceType, :count).by(1)
        assigns(:source_type).should be_a(SourceType)
        assigns(:source_type).should be_persisted
        response.should redirect_to(SourceType.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved source_type as @source_type and re-renders the 'new' template" do
        post :create, {:source_type => invalid_template.attributes}
        assigns(:source_type).should be_a_new(SourceType)
        response.should render_template("new")
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        #SourceType.any_instance.stub(:save).and_return(false)
        post :create, {:source_type => invalid_template.attributes}
        response.should render_template("new")
      end

    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested source_type, assigns it as @source_type, and redirects to show page" do
        put :update, {:id => source_type.to_param, :source_type => valid_template.attributes}
        assigns(:source_type).should eq(source_type)
        response.should redirect_to(source_type)
      end
    end

    describe "with invalid params" do
      it "assigns the source_type as @source_type and re-renders the 'edit' template" do
        put :update, {:id => source_type.to_param, :source_type => invalid_template.attributes}
        assigns(:source_type).should eq(source_type)
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested source_type" do
      expect(source_type).to be_persisted
      expect {
        delete :destroy, {:id => source_type.to_param}
      }.to change{SourceType.current.count}.by(-1)
    end

    it "redirects to the source_types list" do
      delete :destroy, {:id => source_type.to_param}
      response.should redirect_to(source_types_url)
    end
  end
end
