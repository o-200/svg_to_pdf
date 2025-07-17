require 'rails_helper'
require 'prawn'

RSpec.describe PdfDocuments::CropMarksDrawerService do
  let(:pdf) { Prawn::Document.new(page_size: 'A4') }
  let(:params) { { pdf: pdf } }

  subject(:service) { described_class.new(params).tap(&:call) }

  describe "#call" do
    context "with a valid PDF document" do
      it "returns a successful result with the modified PDF" do
        expect(service.result.errors).to be_empty
        expect(service.result.value).to be_a(Prawn::Document)
      end

      it "adds crop marks to the PDF" do
        expect(service.result.value.page_count).to eq(1)
      end
    end

    context "when pdf param is nil" do
      let(:params) { { pdf: nil } }

      it "returns an error for nil PDF input" do
        expect(service.result.errors).to include(:crop_marks_error)
        expect(service.result.value).to be_nil
      end
    end

    context "when PDF drawing fails" do
      before do
        allow(pdf).to receive(:stroke).and_raise(StandardError.new("drawing failure"))
      end

      it "returns an error if stroke raises an exception" do
        expect(service.result.errors).to include(:crop_marks_error)
        expect(service.result.errors[:crop_marks_error]).to match(/Failed to create crop marks: drawing failure/)
        expect(service.result.value).to be_nil
      end
    end
  end
end
