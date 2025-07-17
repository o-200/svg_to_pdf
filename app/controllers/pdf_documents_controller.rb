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

  def show
    service = PdfDocuments::FindService.new(pdf_document_params).call

    if service.success?
      serializer = PdfDocumentSerializer.new(service.value).serialize
      render json: serializer
    else
      respond_with_failure(message: "Not Found", errors: service.errors)
    end
  end

  private

  def pdf_document_params
    params.require(:pdf_document).permit(:id)
  end

  def respond_with_success(message = "OK")
    render json: { result: { message: } }, status: :ok
  end

  def respond_with_failure(message, errors)
    render json: {
      result: {
        message:,
        errors:
      }
    }, status: :unprocessable_entity
  end
end
