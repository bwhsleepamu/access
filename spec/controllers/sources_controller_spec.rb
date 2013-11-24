require 'spec_helper'

describe SourcesController do
  login_user

  let(:source) { create(:source) }
  let(:valid_template) { build(:source) }
  let(:invalid_template) { build(:source, location: nil) }


  describe "GET index" do
    it "assigns all sources as @sources" do
      sources = create_list(:source, 5)
      get :index
      sources.each {|o| expect(assigns(:sources)).to include(o)}
    end
  end

  describe "GET show" do
    it "assigns the requested source as @source" do
      get :show, {:id => source.to_param}
      expect(assigns(:source)).to eq(source)
    end
  end

  describe "GET new" do
    it "assigns a new source as @source" do
      get :new
      expect(assigns(:source)).to be_a_new(Source)
    end
  end

  describe "GET edit" do
    it "assigns the requested source as @source" do
      get :edit, {:id => source.to_param}
      expect(assigns(:source)).to eq(source)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new source, assigns it as @source, and redirects to show page" do
        expect {
          post :create, {:source => valid_template.attributes}
        }.to change(Source, :count).by(1)
        assigns(:source).should be_a(Source)
        assigns(:source).should be_persisted
        response.should redirect_to(Source.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved source as @source and re-renders the 'new' template" do
        post :create, {:source => invalid_template.attributes}
        assigns(:source).should be_a_new(Source)
        response.should render_template("new")
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        #Source.any_instance.stub(:save).and_return(false)
        post :create, {:source => invalid_template.attributes}
        response.should render_template("new")
      end

    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested source, assigns it as @source, and redirects to show page" do
        put :update, {:id => source.to_param, :source => valid_template.attributes}
        assigns(:source).should eq(source)
        response.should redirect_to(source)
      end
    end

    describe "with invalid params" do
      it "assigns the source as @source and re-renders the 'edit' template" do
        put :update, {:id => source.to_param, :source => invalid_template.attributes}
        assigns(:source).should eq(source)
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested source" do
      expect(source).to be_persisted
      expect {
        delete :destroy, {:id => source.to_param}
      }.to change{Source.current.count}.by(-1)
    end

    it "redirects to the sources list" do
      delete :destroy, {:id => source.to_param}
      response.should redirect_to(sources_url)
    end
  end
end
