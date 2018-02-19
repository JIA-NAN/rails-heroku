module AdminHelper
  def admin_login(email, password)
    visit new_admin_session_path

    within('#new_admin') do
      fill_in 'Email', with: email
      fill_in 'Password', with: password
    end

    click_on 'Sign in'
  end
end
