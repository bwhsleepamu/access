# Use to configure basic appearance of template
Contour.setup do |config|

  # Enter your application name here. The name will be displayed in the title of all pages, ex: AppName - PageTitle
  config.application_name = 'DSM Access'

  # If you want to style your name using html you can do so here, ex: <b>App</b>Name
  # config.application_name_html = ''

  # Enter your application version here. Do not include a trailing backslash. Recommend using a predefined constant
  config.application_version = Access::VERSION::STRING

  # Enter your application header background image here.
  # config.header_background_image = 'rails.png'

  # Enter your application header title image here.
  # config.header_title_image = ''

  # Enter the items you wish to see in the menu
  config.menu_items =
      [
          {
              name: 'Resources', display: 'always', path: 'subjects_path', position: 'right', condition: 'true', image: '', image_options: {},
              links: [
                  {name: "Subject Groups", path: "subject_groups_path"}
              ]

          },
          {
              name: 'Resources', display: 'always', path: '', position: 'right', condition: 'true', image: '', image_options: {},
              links: [
                  {name: "Data Dictionary", path: "data_dictionary_index_path"},
                  {name: "Event Dictionary", path: "event_dictionary_index_path"},
                  {divider: true},
                  {name: "Documentations", path: "documentations_path"},
                  {name: "Sources", path: "sources_path"},
                  {divider: true},
                  {name: "Source Types", path: "source_types_path"}

              ]
          },
          {
              name: 'Login', display: 'not_signed_in', path: 'new_user_session_path', position: 'right', condition: 'true'
          },
          {
              name: 'Logout', display: 'signed_in', path: 'destroy_user_session_path', position: 'right', condition: 'true'
          },

      ]

  # Enter an address of a valid RSS Feed if you would like to see news on the sign in page.
  # config.news_feed = ''

  # Enter the max number of items you want to see in the news feed.
  # config.news_feed_items = 5

  # The following three parameters can be set as strings, which will rotate through the colors on a daily basis, selecting an index using (YearDay % ArraySize)

  # A string or array of strings that represent a CSS color code for generic link color
  # config.link_color = nil

  # A string or array of strings that represent a CSS color code for the body background color
  # config.body_background_color = nil

  # A string or array of strings that represent an image url for the body background image
  # config.body_background_image = nil

  # A hash where the key is a string in "month-day" format where values are a hash of the link_color, body_background_color and/or body_background_image
  # An example might be (April 1st), { "4-1" => { body_background_image: 'aprilfools.jpg' } }
  # Note the lack of leading zeros!
  # Special days take precendence over the rotating options given above
  # config.month_day = {}

  # An array of hashes that specify additional fields to add to the sign up form
  # An example might be [ { attribute: 'first_name', type: 'text_field' }, { attribute: 'last_name', type: 'text_field' } ]
  # config.sign_up_fields = []
end