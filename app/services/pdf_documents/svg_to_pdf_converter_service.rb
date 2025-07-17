require "prawn"
require "prawn-svg"

module PdfDocuments
  class SvgToPdfConverterService < ApplicationService
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
      validate_params!

      pdf = format_svg_to_pdf(params[:svg]).value

      if errors.none?
        draw_crop_marks(pdf)
        add_watermark(pdf)
        Result.new(value: pdf, errors:)
      else
        Result.new(errors:)
      end
    end

    def validate_params!
      errors.merge!(file_not_found: "SVG photo is missing") if params[:svg].blank?
      errors.merge!(watermark_not_found: "Watermark missing") if params[:watermark].blank?
    end

    def format_svg_to_pdf(svg)
      begin
        pdf = Prawn::Document.new(margin: 36)
        pdf.svg(svg, at: [ 0, pdf.cursor ], width: 500)
        Result.new(value: pdf, errors:)
      rescue => e
        errors.merge!(invalid_svg: "Invalid SVG content: #{e.message}")
        Result.new(errors:)
      end
    end

    def draw_crop_marks(pdf)
      service = CropMarksDrawerService.new(pdf:).call

      if service.success?
        service.value
      else
        errors.merge!(service.errors)
      end
    end

    def add_watermark(pdf)
      pdf.go_to_page(1)
      pdf.fill_color "cccccc"
      pdf.rotate(45, origin: [ 0, 0 ]) do
        pdf.draw_text(params[:watermark], at: [ 100, 100 ], size: 100)
      end
    end

    def errors
      @errors ||= {}
    end
  end
end
