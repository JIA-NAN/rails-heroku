module DashboardHelper

  def display_sequences(sequences, active)
    display_subnav('Sequences', sequences, active) do |seq|
      link_to seq.name, grading_path(id: seq.id)
    end
  end

end
