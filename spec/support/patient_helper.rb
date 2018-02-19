module PatientHelper
  def patient_login(id, password)
    visit new_patient_session_path

    within('#new_patient') do
      fill_in 'Login ID', with: id
      fill_in 'Password', with: password
    end

    click_on 'Sign in'
  end
end
