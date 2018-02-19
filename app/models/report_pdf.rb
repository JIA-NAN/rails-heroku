require 'render_anywhere'
include RecordsHelper
class ReportPdf
  include RenderAnywhere
  def initialize(patient, schedule)
    @patient = patient
    @schedule = schedule
  end

  def to_pdf
    PDFKit.configure do |config|
      config.wkhtmltopdf = `which wkhtmltopdf`.to_s.strip
      config.default_options = {
        encoding: 'UTF-8',
        margin_top: '1in',
        margin_right: '1in',
        margin_bottom: '1in',
        margin_left: '1in',
        # zoom: 3.4,  # for localhost
        zoom: 1,
        header_right: 'Page [page] of [toPage]',
        disable_smart_shrinking: false,
        print_media_type: false,
        dpi: 1000
      }
    end

    kit = PDFKit.new(as_html,
      header_left: 'MIST report',
      footer_left: 'Mobile Interactive Supervised Therapy',
      footer_line: true,
      header_line: true,
      header_spacing: 9,
      footer_spacing: 9)
    kit.to_file("#{Rails.root}/public/report.pdf")
  end

  def filename
    "Report_#{@patient.id}.pdf"
  end

  private

  attr_reader :patient, :schedule
  def as_html
    render template: 'reports/pdf', layout: 'invoice_pdf', locals: { patient: patient, schedule: schedule }
  end
end
