require 'spec_helper'

describe DocumentationsController do
  login_user

  let(:documentation) { create(:documentation) }
  let(:valid_template) { build(:documentation) }
  let(:invalid_template) { build(:documentation, title: nil) }


  describe "GET index" do
    it "assigns all documentations as @documentations" do
      documentations = create_list(:documentation, 5)
      get :index
      documentations.each {|o| expect(assigns(:documentations)).to include(o)}
    end
  end

  describe "GET show" do
    it "assigns the requested documentation as @documentation" do
      get :show, {:id => documentation.to_param}
      expect(assigns(:documentation)).to eq(documentation)
    end
  end

  describe "GET new" do
    it "assigns a new documentation as @documentation" do
      get :new
      expect(assigns(:documentation)).to be_a_new(Documentation)
    end
  end

  describe "GET edit" do
    it "assigns the requested documentation as @documentation" do
      get :edit, {:id => documentation.to_param}
      expect(assigns(:documentation)).to eq(documentation)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new documentation, assigns it as @documentation, and redirects to show page" do
        expect {
          post :create, {:documentation => valid_template.attributes}
        }.to change(Documentation, :count).by(1)
        expect(assigns(:documentation)).to be_a(Documentation)
        expect(assigns(:documentation)).to be_persisted
        expect(response).to redirect_to(Documentation.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved documentation as @documentation and re-renders the 'new' template" do
        post :create, {:documentation => invalid_template.attributes}
        expect(assigns(:documentation)).to be_a_new(Documentation)
        expect(response).to render_template("new")
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        #Documentation.any_instance.stub(:save).and_return(false)
        post :create, {:documentation => invalid_template.attributes}
        expect(response).to render_template("new")
      end

    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested documentation, assigns it as @documentation, and redirects to show page" do
        put :update, {:id => documentation.to_param, :documentation => valid_template.attributes}
        expect(assigns(:documentation)).to eq(documentation)
        expect(response).to redirect_to(documentation)
      end
    end

    describe "with invalid params" do
      it "assigns the documentation as @documentation and re-renders the 'edit' template" do
        put :update, {:id => documentation.to_param, :documentation => invalid_template.attributes}
        expect(assigns(:documentation)).to eq(documentation)
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested documentation" do
      expect(documentation).to be_persisted
      expect {
        delete :destroy, {:id => documentation.to_param}
      }.to change{Documentation.current.count}.by(-1)
    end

    it "redirects to the documentations list" do
      delete :destroy, {:id => documentation.to_param}
      expect(response).to redirect_to(documentations_url)
    end
  end
end
