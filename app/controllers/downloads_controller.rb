class DownloadsController < ApplicationController
  before_filter :authenticate_admin!
  def invoice
    patient = Patient.find(params[:patient_id])
    schedule = Schedule.find(params[:schedule_id])

    respond_to do |format|
      format.pdf { send_invoice_pdf }
      format.html { render template: 'invoices/pdf', layout: 'invoice_pdf', locals: { patient: patient, schedule: schedule }}
    end
  end

  def report
    patient = Patient.find(params[:patient_id])
    schedule = Schedule.find(params[:schedule_id])

    respond_to do |format|
      format.pdf { send_report_pdf }
      format.csv { send_report_csv }
      format.html {
        render template: 'reports/pdf',
               layout: 'invoice_pdf',
               locals: { patient: patient, schedule: schedule }
      }
    end
  end

  private

  def invoice_pdf
    @patient = Patient.find(params[:patient_id])
    @schedule = Schedule.find(params[:schedule_id])
    InvoicePdf.new(@patient, @schedule)
  end

  def report_pdf
    @patient = Patient.find(params[:patient_id])
    @schedule = Schedule.find(params[:schedule_id])
    ReportPdf.new(@patient, @schedule)
  end

  def report_csv
    @patient = Patient.find(params[:patient_id])
    @schedule = Schedule.find(params[:schedule_id])
    CSV.generate(headers: true) do |csv|
      attributes = %w{id lastname firstname}
      headers = ['Patient ID', 'Last Name', 'First Name']
      csv << headers
      csv << attributes.map { |attr| @patient.send(attr) }
      csv << ['', '']
      headers = ['Schedule ID', 'Start Time', 'End Time']
      csv << headers
      attributes = %w{id started_at terminated_at}
      csv << attributes.map { |attr| @schedule.send(attr) }
      csv << ['']
      attributes = %w{id received pill_time_at actual_pill_time_at comment}
      headers = ['Record ID', 'Video Received?', 'Scheduled Medication Time', 'Video Recorded Time',
                 'Record: Comment', 'Grade: Comment', 'Grade: Note', 'Grade: Medication Taken?',
                 'Grade: Explanation', 'Auto: Face Recognition Score', 'Auto: Is Face Recognized?',
                 'Auto: Medication Taken?']
      csv << headers
      @patient.records.from_period(@schedule.started_at, @schedule.terminated_at).each do |record|
        row = Array.new
        row.concat(attributes.map { |attr| record.send(attr) })
        if record.graded
          row.concat([record.grade.comment,
                      record.grade.note,
                      record.grade.pill_taken,
                      record.grade.explanation])
        else
          row.concat(['', '', '', ''])
        end
        if record.auto_grade
          row.concat([record.auto_grade.face_recognition_score,
                       record.auto_grade.is_face_recognized,
                       record.auto_grade.is_pill_taken])
        else
          row.concat(['', '', ''])
        end
        csv << row
      end
    end
  end

  def send_invoice_pdf
    send_file invoice_pdf.to_pdf,
              filename: invoice_pdf.filename,
              type: 'application/pdf',
              disposition: 'inline'
  end

  def send_report_csv
    send_data report_csv, filename: "report-#{Date.today}.csv"
  end

  def send_report_pdf
    send_file report_pdf.to_pdf,
              filename: report_pdf.filename,
              type: 'application/pdf',
              disposition: 'inline'
  end
end
