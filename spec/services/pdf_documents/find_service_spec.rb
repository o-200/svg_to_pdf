require 'rails_helper'

RSpec.describe PdfDocuments::FindService do
  let!(:record) do
    PdfDocument.create!(
      filename: "existing.pdf",
      watermark: "Test Watermark",
      source_type: "svg",
      metadata: { original_svg_preview: "<svg></svg>" }
    )
  end

  subject(:service) { described_class.new(params).call }

  describe "#call" do
    context "when a matching record exists" do
      let(:params) { { id: record.id } }

      it "returns a successful result with the found record" do
        expect(service.errors).to be_empty
        expect(service.value).to eq(record)
      end
    end

    context "when no matching record is found" do
      let(:params) { { id: record.id } }

      it "returns an error for not_found" do
        expect(service.value).to be_nil
        expect(service.errors).to include(:not_found)
        expect(service.errors[:not_found]).to eq({ id: record.id })
      end
    end

    context "when params are empty" do
      let(:params) { {} }

      it "returns nil value and no errors" do
        expect(service.value).to be_nil
        expect(service.errors).to eq(not_found: {})
      end
    end

    context "when find_by raises an exception" do
      let(:params) { { filename: "invalid_id" } }

      it "returns not_found error" do
        expect(service.value).to be_nil
        expect(service.errors).to include(:not_found)
      end
    end
  end
end
