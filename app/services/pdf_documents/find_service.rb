module PdfDocuments
  class FindService < ApplicationService
    attr_accessor :params,
                  :result

    def initialize(params)
      @params = params
    end

    def call
      begin
        document = PdfDocument.find_by(id: params[:id])
        self.result = process(document)
      rescue
        self.result = Result.new(errors: { not_found: params })
      end
    end

    private

    def process(document)
      if document
        Result.new(value: document, errors: errors)
      else
        raise "document not found"
      end
    end

    def errors
      {}
    end
  end
end
