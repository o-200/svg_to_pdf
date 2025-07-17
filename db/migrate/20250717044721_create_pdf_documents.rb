class CreatePdfDocuments < ActiveRecord::Migration[8.0]
  def change
    create_table :pdf_documents do |t|
      t.string :filename
      t.string :watermark
      t.string :source_type
      t.json :metadata

      t.timestamps
    end
  end
end
