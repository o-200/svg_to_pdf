require 'rails_helper'

RSpec.describe PdfDocuments::CreateService do
  let(:valid_params) do
    {
      filename: "custom_name.pdf",
      watermark: "CONFIDENTIAL",
      svg: "<svg><circle /></svg>"
    }
  end

  subject(:service) { described_class.new(params).tap(&:call) }

  describe "#call" do
    context "with valid parameters" do
      let(:params) { valid_params }

      it "creates a PdfDocument record successfully" do
        expect { service }.to change(PdfDocument, :count).by(1)
        expect(service.result.errors).to be_empty
        expect(service.result.value).to be_a(PdfDocument)
        expect(service.result.value.filename).to eq("custom_name.pdf")
      end
    end

    context "with missing filename" do
      let(:params) { valid_params.except(:filename) }

      it "generates a filename automatically" do
        service
        expect(service.result.value.filename).to match(/^generated_\d+\.pdf$/)
      end
    end

    context "with database error" do
      let(:params) { valid_params }

      before do
        allow(PdfDocument).to receive(:create).and_raise(StandardError.new("cl connection failed"))
      end

      it "returns a db_error if creation fails" do
        expect(service.result.errors).to include(:db_error)
        expect(service.result.errors[:db_error]).to match(/Failed to create record:/)
        expect(service.result.value).to be_nil
      end
    end

    context "with invalid params (e.g. missing required fields)" do
      let(:params) { {} }

      it "creates a record with defaults and missing data" do
        expect { service }.to change(PdfDocument, :count).by(1)
        expect(service.result.value.filename).to match(/^generated_\d+\.pdf$/)
        expect(service.result.value.watermark).to be_nil
      end
    end
  end
end
