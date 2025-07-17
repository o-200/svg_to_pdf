module PdfDocuments
  class FindService < ApplicationService
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
      document = PdfDocument.find_by(id: params[:id])
      if document
        Result.new(value: document, errors: errors)
      else
        errors.merge!(not_found: "Document not found")
        Result.new(errors: errors)
      end
    end

    def errors
      @errors ||= {}
    end
  end
end
