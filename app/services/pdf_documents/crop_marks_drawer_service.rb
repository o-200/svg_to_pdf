require "prawn"

module PdfDocuments
  class CropMarksDrawerService < ApplicationService
    attr_accessor :pdf,
                  :result

    def initialize(params)
      @pdf = params[:pdf]
    end

    def call
      self.result = process
    end

    private

    def process
      begin
        length = 15
        offset = 10
        width = pdf.bounds.width
        height = pdf.bounds.height

        pdf.stroke do
          pdf.line [ offset, height - offset ], [ offset + length, height - offset ]
          pdf.line [ offset, height - offset ], [ offset, height - offset - length ]
        end

        pdf.stroke do
          pdf.line [ width - offset, height - offset ], [ width - offset - length, height - offset ]
          pdf.line [ width - offset, height - offset ], [ width - offset, height - offset - length ]
        end

        pdf.stroke do
          pdf.line [ offset, offset ], [ offset + length, offset ]
          pdf.line [ offset, offset ], [ offset, offset + length ]
        end

        pdf.stroke do
          pdf.line [ width - offset, offset ], [ width - offset - length, offset ]
          pdf.line [ width - offset, offset ], [ width - offset, offset + length ]
        end

        Result.new(value: pdf, errors:)
      rescue => e
        errors.merge!(crop_marks_error: "Failed to create crop marks: #{e.message}")
        Result.new(errors:)
      end
    end

    def errors
      @errors ||= {}
    end
  end
end
