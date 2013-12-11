require 'spec_helper'

describe DataTypesController do
  login_user

  let(:data_type) { create(:data_type) }
  let(:valid_template) { build(:data_type) }
  let(:invalid_template) { build(:data_type, name: nil) }


  describe "GET index" do
    it "assigns all data_types as @data_types" do
      data_types = create_list(:data_type, 5)
      get :index
      data_types.each {|o| expect(assigns(:data_types)).to include(o)}
    end
  end

  describe "GET show" do
    it "assigns the requested data_type as @data_type" do
      get :show, {:id => data_type.to_param}
      expect(assigns(:data_type)).to eq(data_type)
    end
  end

  describe "GET new" do
    it "assigns a new data_type as @data_type" do
      get :new
      expect(assigns(:data_type)).to be_a_new(DataType)
    end
  end

  describe "GET edit" do
    it "assigns the requested data_type as @data_type" do
      get :edit, {:id => data_type.to_param}
      expect(assigns(:data_type)).to eq(data_type)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new data_type, assigns it as @data_type, and redirects to show page" do
        expect {
          post :create, {:data_type => valid_template.attributes}
        }.to change(DataType, :count).by(1)
        expect(assigns(:data_type)).to be_a(DataType)
        expect(assigns(:data_type)).to be_persisted
        expect(response).to redirect_to(DataType.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved data_type as @data_type and re-renders the 'new' template" do
        post :create, {:data_type => invalid_template.attributes}
        expect(assigns(:data_type)).to be_a_new(DataType)
        expect(response).to render_template("new")
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        #DataType.any_instance.stub(:save).and_return(false)
        post :create, {:data_type => invalid_template.attributes}
        expect(response).to render_template("new")
      end

    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested data_type, assigns it as @data_type, and redirects to show page" do
        put :update, {:id => data_type.to_param, :data_type => valid_template.attributes}
        expect(assigns(:data_type)).to eq(data_type)
        expect(response).to redirect_to(data_type)
      end
    end

    describe "with invalid params" do
      it "assigns the data_type as @data_type and re-renders the 'edit' template" do
        put :update, {:id => data_type.to_param, :data_type => invalid_template.attributes}
        expect(assigns(:data_type)).to eq(data_type)
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested data_type" do
      expect(data_type).to be_persisted
      expect {
        delete :destroy, {:id => data_type.to_param}
      }.to change{DataType.current.count}.by(-1)
    end

    it "redirects to the data_types list" do
      delete :destroy, {:id => data_type.to_param}
      expect(response).to redirect_to(data_types_url)
    end
  end
end
