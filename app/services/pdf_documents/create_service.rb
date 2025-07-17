module PdfDocuments
  class CreateService < ApplicationService
    attr_accessor :params,
                  :result

    def initialize(params)
      @params = params
    end

    def call
      self.result = process
    end

    private

    def process
      create_record(params)
    end

    def create_record(params)
      record = PdfDocument.create(pdf_params(params))
      Result.new(value: record, errors:)
    rescue => e
      errors.merge!(db_error: "Failed to create record: #{e.message}")
      Result.new(errors:)
    end

    def pdf_params(params)
      {
        filename: params[:filename] || "generated_#{Time.now.to_i}.pdf",
        watermark: params[:watermark],
        source_type: "svg",
        metadata: {
          original_svg_preview: params[:svg].to_s.truncate(500)
        }
      }
    end

    def errors
      @errors ||= {}
    end
  end
end
