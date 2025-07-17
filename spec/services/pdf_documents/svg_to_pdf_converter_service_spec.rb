require 'rails_helper'

RSpec.describe PdfDocuments::SvgToPdfConverterService do
  let(:valid_svg) do
    <<-SVG
      <svg xmlns="http://www.w3.org/2000/svg" width="100" height="100">
        <circle cx="50" cy="50" r="40" stroke="green" stroke-width="4" fill="yellow" />
      </svg>
    SVG
  end

  let(:invalid_svg) { "<svg><invalid></svg>" }
  let(:watermark) { "CONFIDENTIAL" }

  subject(:service) { described_class.new(params).call }

  describe "#call" do
    context "with valid params" do
      let(:params) { { svg: valid_svg, watermark: watermark } }

      it "returns a successful result with a PDF" do
        expect(service.errors).to be_empty
        expect(service.value).to be_a(Prawn::Document)
      end
    end

    context "with missing SVG" do
      let(:params) { { svg: nil, watermark: watermark } }

      it "returns an error for missing SVG" do
        expect(service.errors).to include(:file_not_found)
        expect(service.value).to be_nil
      end
    end

    context "with missing watermark" do
      let(:params) { { svg: valid_svg, watermark: nil } }

      it "returns an error for missing watermark but still generates PDF" do
        expect(service.errors).to include(:watermark_not_found)
        expect(service.value).to be_nil
      end
    end

    context "with invalid SVG" do
      let(:params) { { svg: invalid_svg, watermark: watermark } }

      it "returns an error for invalid SVG" do
        expect(service.errors).to include(:invalid_svg)
        expect(service.value).to be_nil
      end
    end
  end
end
