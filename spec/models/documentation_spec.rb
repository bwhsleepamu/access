require 'spec_helper'

describe Documentation do
  context "complex associations" do
    it "should add more supporting docs" do
      supporting_docs = create_list(:documentation, 3)

      d = build(:documentation)
      d.supporting_documentations = supporting_docs
      expect(d.save).to be_true
      d.reload

      expect(d.supporting_documentations).to eq(supporting_docs)

      MY_LOG.info "list: #{DocumentationsSupportingDocumentation.all.to_a}"

      supporting_docs.each do |sd|
        sd.reload
        MY_LOG.info sd.documentations_supported_documentations.to_a
        expect(sd.supported_documentations.length).to eq(1)
        expect(sd.supported_documentations.first).to eq(d)
      end
    end

    it "should add links" do

    end
  end
end
