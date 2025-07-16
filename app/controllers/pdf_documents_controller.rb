class PdfDocumentsController < ApplicationController
  def index
  end

  def create
    svg = params[:file].read
    watermark = "Alex Abramov" # params[:watermark]

    service = PdfDocuments::SvgToPdfConverterService.new({ svg:, watermark: }).call
    if service.success?
      send_data service.value.render, filename: "result.pdf", type: "application/pdf", disposition: "inline"
    else
      respond_with_failure(message: "Can't process SVG", errors: service.errors)
    end
  end

  private

  def respond_with_failure(message, errors)
    render json: {
      result: {
        message:,
        errors:
      }
    }, status: :unprocessable_entity
  end
end
