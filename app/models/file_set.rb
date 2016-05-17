# Generated by curation_concerns:models:install
class FileSet < ActiveFedora::Base
  include ::CurationConcerns::FileSetBehavior
  Hydra::Derivatives.output_file_service = PersistPairtreeDerivatives

  apply_schema IIIFPageSchema, ActiveFedora::SchemaIndexingStrategy.new(
    ActiveFedora::Indexers::GlobalIndexer.new([:stored_searchable, :symbol])
  )
  after_save :touch_parent_works

  validates_with ViewingHintValidator

  def self.image_mime_types
    []
  end

  def iiif_path
    IIIFPath.new(id).to_s
  end

  def create_derivatives(filename)
    case mime_type
    when 'image/tiff'
      Hydra::Derivatives::Jpeg2kImageDerivatives.create(
        filename,
        outputs: [
          label: 'intermediate_file',
          service: {
            datastream: 'intermediate_file',
            recipe: :default
          },
          url: derivative_url('intermediate_file')
        ]
      )
      OCRRunner.new(self).from_file(filename)
    end
    super
  end

  def to_solr(solr_doc = {})
    super.tap do |doc|
      doc["full_text_tesim"] = ocr_text if ocr_text.present?
      doc["ordered_by_ssim"] = ordered_by.map(&:id).to_a
    end
  end

  def ocr_document
    return unless persisted? && File.exist?(ocr_file.gsub("file:", ""))
    @ocr_document ||=
      begin
        file = File.open(ocr_file.gsub("file:", ""))
        HOCRDocument.new(file)
      end
  end

  private

    def touch_parent_works
      in_works.each(&:update_index)
    end

    def ocr_file
      derivative_url('ocr')
    end

    def ocr_text
      ocr_document.try(:text).try(:strip)
    end

    # The destination_name parameter has to match up with the file parameter
    # passed to the DownloadsController
    def derivative_url(destination_name)
      path = PairtreeDerivativePath.derivative_path_for_reference(self, destination_name)
      URI("file://#{path}").to_s
    end
end
