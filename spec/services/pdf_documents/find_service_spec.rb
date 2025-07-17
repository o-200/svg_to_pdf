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

  subject(:service) { described_class.new(params).tap(&:call) }

  describe "#call" do
    context "when a matching record exists" do
      let(:params) { { id: record.id } }

      it "returns a successful result with the found record" do
        expect(service.result.errors).to be_empty
        expect(service.result.value).to eq(record)
      end
    end

    context "when no matching record is found" do
      let(:params) { { id: -1 } }

      it "returns an error for not_found" do
        expect(service.result.value).to be_nil
        expect(service.result.errors).to include(:not_found)
        expect(service.result.errors[:not_found]).to eq({ id: -1 })
      end
    end

    context "when params are empty" do
      let(:params) { {} }

      it "returns nil value and no errors" do
        expect(service.result.value).to be_a(PdfDocument).or be_nil
        expect(service.result.errors).to eq({})
      end
    end

    context "when find_by raises an exception" do
      let(:params) { { id: "invalid_id" } }

      before do
        allow(PdfDocument).to receive(:find_by).and_raise(ActiveRecord::RecordNotFound)
      end

      it "handles ActiveRecord::RecordNotFound and returns not_found error" do
        expect(service.result.value).to be_nil
        expect(service.result.errors).to include(:not_found)
      end
    end
  end
end
