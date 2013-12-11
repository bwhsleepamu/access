module FeatureMacros
  def show_page(name)
    save_screenshot("/usr/local/htdocs/access/spec/screenshots/#{name}.png", full: true)
    #page.driver.render("/home/pwm4/Documents/websites/#{name}.png", :full => true)
  end

  def login_user
    password = "secret"
    user = create(:active_user, password: password)
    visit new_user_session_path
    fill_in('Email', :with => user.email)
    fill_in('Password', :with => password)
    click_button("Sign in")
    user
  end

  def login_admin
    password = "secret"
    user = create(:admin, password: password)
    visit new_user_session_path
    fill_in('Email', :with => user.email)
    fill_in('Password', :with => password)
    click_button("Sign in")

    user
  end

  def select_from_chosen(item_text, options)
    field = find_field(options[:from], visible: false)
    option_value = page.evaluate_script("$(\"##{field[:id]} option:contains('#{item_text}')\").val()")
    page.execute_script("value = ['#{option_value}']\; if ($('##{field[:id]}').val()) {$.merge(value, $('##{field[:id]}').val())}")
    option_value = page.evaluate_script("value")
    page.execute_script("$('##{field[:id]}').val(#{option_value})")
    page.execute_script("$('##{field[:id]}').trigger('liszt:updated').trigger('change')")
  end

end