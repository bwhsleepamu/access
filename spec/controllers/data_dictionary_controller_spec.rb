require 'spec_helper'

describe DataDictionaryController do
  login_user
  let(:data_dictionary) { create(:data_dictionary) }
  let(:valid_template) { build(:data_dictionary) }
  let(:invalid_template) { build(:data_dictionary, title: nil) }

  describe "GET index" do
    it "assigns all data_dictionary as @data_dictionary" do
      data_dictionary = create_list(:data_dictionary, 5)
      get :index
      data_dictionary.each {|o| expect(assigns(:data_dictionary)).to include(o)}
    end
  end

  describe "GET show" do
    it "assigns the requested data_dictionary as @data_dictionary" do
      get :show, {:id => data_dictionary.to_param}
      expect(assigns(:data_dictionary)).to eq(data_dictionary)
    end
  end

  describe "GET new" do
    it "assigns a new data_dictionary as @data_dictionary" do
      get :new
      expect(assigns(:data_dictionary)).to be_a_new(DataDictionary)
    end
  end

  describe "GET edit" do
    it "assigns the requested data_dictionary as @data_dictionary" do
      get :edit, {:id => data_dictionary.to_param}
      expect(assigns(:data_dictionary)).to eq(data_dictionary)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new data_dictionary, assigns it as @data_dictionary, and redirects to show page" do
        expect {
          post :create, {:data_dictionary => valid_template.attributes}
        }.to change(DataDictionary, :count).by(1)

        expect(assigns(:data_dictionary)).to be_a(DataDictionary)
        expect(assigns(:data_dictionary)).to be_persisted
        expect(response).to redirect_to(DataDictionary.last)
      end

      it "creates a new DataDictionary with Allowed Values and ranges" do
        data_type = create(:integer_type)
        expect {
          post :create,
            {
              :data_dictionary => {"title"=>"data_record_1", "description"=>"Some description that may be fun.", "data_type_id"=>data_type.id, "multivalue"=>"0", "unit"=>"mm", "min_value"=>"0", "min_value_inclusive"=>"0", "max_value"=>"10", "max_value_inclusive"=>"0", "allowed_values"=>["0", "1", "2", "3", "4", "5"]}
            }
        }.to change(DataDictionary, :count).by(1)

        expect(assigns(:data_dictionary).allowed_data_values.length).to eq 6
        expect(assigns(:data_dictionary).min_value).to eq 0
        expect(assigns(:data_dictionary).max_value).to eq 10
        expect(assigns(:data_dictionary)).to be_a(DataDictionary)
        expect(assigns(:data_dictionary)).to be_persisted
        response.should redirect_to(DataDictionary.last)
    end

    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved data_dictionary as @data_dictionary and re-renders the 'new' template" do
        post :create, {:data_dictionary => invalid_template.attributes}
        expect(assigns(:data_dictionary)).to be_a_new(DataDictionary)
        expect(response).to render_template("new")
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        #DataDictionary.any_instance.stub(:save).and_return(false)
        post :create, {:data_dictionary => invalid_template.attributes}
        expect(response).to render_template("new")
      end

    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested data_dictionary, assigns it as @data_dictionary, and redirects to show page" do
        put :update, {:id => data_dictionary.to_param, :data_dictionary => valid_template.attributes}
        assigns(:data_dictionary).should eq(data_dictionary)
        response.should redirect_to(data_dictionary)
      end
    end

    describe "with invalid params" do
      it "assigns the data_dictionary as @data_dictionary and re-renders the 'edit' template" do
        put :update, {:id => data_dictionary.to_param, :data_dictionary => invalid_template.attributes}
        assigns(:data_dictionary).should eq(data_dictionary)
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested data_dictionary" do
      expect(data_dictionary).to be_persisted
      expect {
        delete :destroy, {:id => data_dictionary.to_param}
      }.to change{DataDictionary.current.count}.by(-1)
    end

    it "redirects to the data_dictionary list" do
      delete :destroy, {:id => data_dictionary.to_param}
      response.should redirect_to(data_dictionary_index_url)
    end
  end
end
