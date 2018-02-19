require "render_anywhere"
 
class InvoicePdf
  include RenderAnywhere
 
  def initialize(patient, schedule)
    @patient = patient
    @schedule = schedule

    
  end
 
  def to_pdf

    PDFKit.configure do |config|
      config.wkhtmltopdf = `which wkhtmltopdf`.to_s.strip
      config.default_options = {
      :encoding=>"UTF-8",
      :page_size=>"Letter", #or "Letter" or whatever needed
      :margin_top=>"1in",
      :margin_right=>"1in",
      :margin_bottom=>"1in",
      :margin_left=>"1in",
      :header_right => "Page [page] of [toPage]",
      :disable_smart_shrinking=>false,
       :dpi => 300
      }
    end

    kit = PDFKit.new(as_html, page_size: 'A4', :header_left => "MIST invoice", 
        :footer_left => "Mobile Interactive Supervised Therapy", 
        :footer_line => true, 
        :header_line => true, 
        :header_spacing => 9, 
        :footer_spacing => 9 )
    kit.to_file("#{Rails.root}/public/invoice.pdf")
  end
 
  def filename

    "Invoice_#{@patient.id}.pdf"
    
  end
 
  private
 
    attr_reader :patient, :schedule
 
    def as_html
      render template: "invoices/pdf", layout: "invoice_pdf", locals: { patient: patient, schedule: schedule }
    end
end