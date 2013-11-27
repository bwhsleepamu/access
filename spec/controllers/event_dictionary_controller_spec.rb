require 'spec_helper'

describe DocumentationsController do
  login_user

  let(:event_dictionary) { create(:event_dictionary) }
  let(:valid_template) { build(:event_dictionary) }
  let(:invalid_template) { build(:event_dictionary, title: nil) }


  describe "GET index" do
    it "assigns all event_dictionary as @event_dictionary" do
      event_dictionary = create_list(:event_dictionary, 5)
      get :index
      event_dictionary.each {|o| expect(assigns(:event_dictionary)).to include(o)}
    end
  end

  describe "GET show" do
    it "assigns the requested event_dictionary as @event_dictionary" do
      get :show, {:id => event_dictionary.to_param}
      expect(assigns(:event_dictionary)).to eq(event_dictionary)
    end
  end

  describe "GET new" do
    it "assigns a new event_dictionary as @event_dictionary" do
      get :new
      expect(assigns(:event_dictionary)).to be_a_new(EventDictionary)
    end
  end

  describe "GET edit" do
    it "assigns the requested event_dictionary as @event_dictionary" do
      get :edit, {:id => event_dictionary.to_param}
      expect(assigns(:event_dictionary)).to eq(event_dictionary)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new event_dictionary, assigns it as @event_dictionary, and redirects to show page" do
        expect {
          post :create, {:event_dictionary => valid_template.attributes}
        }.to change(EventDictionary, :count).by(1)
        expect(assigns(:event_dictionary)).to be_a(EventDictionary)
        expect(assigns(:event_dictionary)).to be_persisted
        expect(response).to redirect_to(EventDictionary.last)
      end


      it "creates a new EventDictionary with data records and event tags" do
        expect {
          event_tags = create_list(:event_tag, 3)
          data_records = create_list(:data_dictionary, 3)

          attrs = valid_template.attributes
          attrs[:event_tag_ids] = event_tags.collect{ |et| et.id }
          attrs[:data_dictionary_ids] = data_records.collect {|dd| dd.id}

          post :create, {:event_dictionary => attrs}
        }.to change(EventDictionary, :count).by(1)
        expect(assigns(:event_dictionary)).to be_a(EventDictionary)
        expect(assigns(:event_dictionary)).to be_persisted
        expect(assigns(:event_dictionary).event_tags.length).to eq 3
        expect(assigns(:event_dictionary).data_dictionary.length).to eq 3
        expect(response).to redirect_to(EventDictionary.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved event_dictionary as @event_dictionary and re-renders the 'new' template" do
        post :create, {:event_dictionary => invalid_template.attributes}
        expect(assigns(:event_dictionary)).to be_a_new(EventDictionary)
        expect(response).to render_template("new")
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        #EventDictionary.any_instance.stub(:save).and_return(false)
        post :create, {:event_dictionary => invalid_template.attributes}
        expect(response).to render_template("new")
      end

    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested event_dictionary, assigns it as @event_dictionary, and redirects to show page" do
        put :update, {:id => event_dictionary.to_param, :event_dictionary => valid_template.attributes}
        expect(assigns(:event_dictionary)).to eq(event_dictionary)
        expect(response).to redirect_to(event_dictionary)
      end
    end

    describe "with invalid params" do
      it "assigns the event_dictionary as @event_dictionary and re-renders the 'edit' template" do
        put :update, {:id => event_dictionary.to_param, :event_dictionary => invalid_template.attributes}
        expect(assigns(:event_dictionary)).to eq(event_dictionary)
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested event_dictionary" do
      expect(event_dictionary).to be_persisted
      expect {
        delete :destroy, {:id => event_dictionary.to_param}
      }.to change{EventDictionary.current.count}.by(-1)
    end

    it "redirects to the event_dictionary list" do
      delete :destroy, {:id => event_dictionary.to_param}
      expect(response).to redirect_to(event_dictionary_index_url)
    end
  end
end
