class PdfDocumentSerializer
  include Alba::Resource

  root_key :pdf_document

  attributes :id, :filename, :watermark, :source_type

  attribute :preview_svg_snippet do |pdf|
    pdf.metadata["original_svg_preview"].to_s.truncate(200)
  end

  attribute :created_at do |pdf|
    pdf.created_at.strftime("%Y-%m-%d %H:%M:%S")
  end

  attribute :updated_at do |pdf|
    pdf.updated_at.strftime("%Y-%m-%d %H:%M:%S")
  end
end
