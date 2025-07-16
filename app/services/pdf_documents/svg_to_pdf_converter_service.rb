require 'prawn'
require 'prawn-svg'

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
        pdf = Prawn::Document.new(
          page_size: 'A4',
          margin: 36
        )
        pdf.svg(svg, at: [0, pdf.cursor], width: 500)
        Result.new(value: pdf, errors:)
      rescue => e
        errors.merge!(invalid_svg: "Invalid SVG content: #{e.message}")
        Result.new(errors:)
      end
    end

    def draw_crop_marks(pdf)
      length = 15
      offset = 10
      width = pdf.bounds.width
      height = pdf.bounds.height

      pdf.stroke do
        pdf.line [offset, height - offset], [offset + length, height - offset]
        pdf.line [offset, height - offset], [offset, height - offset - length]
      end

      pdf.stroke do
        pdf.line [width - offset, height - offset], [width - offset - length, height - offset]
        pdf.line [width - offset, height - offset], [width - offset, height - offset - length]
      end

      pdf.stroke do
        pdf.line [offset, offset], [offset + length, offset]
        pdf.line [offset, offset], [offset, offset + length]
      end

      pdf.stroke do
        pdf.line [width - offset, offset], [width - offset - length, offset]
        pdf.line [width - offset, offset], [width - offset, offset + length]
      end
    end

    def add_watermark(pdf)
      pdf.go_to_page(1)
      pdf.fill_color "cccccc"
      pdf.rotate(45, origin: [0, 0]) do
        pdf.draw_text(params[:watermark], at: [100, 100], size: 50)
      end
    end

    def errors
      @errors ||= {}
    end
  end
end
