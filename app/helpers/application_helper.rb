module ApplicationHelper
  # Prints out '6 hours ago, Yesterday, 2 weeks ago, 5 months ago, 1 year ago'
  def recent_activity(past_time)
    return '' unless past_time.kind_of?(Time)
    time_ago_in_words(past_time)
    seconds_ago = (Time.zone.now - past_time)
    color = if seconds_ago < 60.minute then "#6DD1EC"
            elsif seconds_ago < 1.day then "#ADDD1E"
            elsif seconds_ago < 2.day then "#CEDC34"
            elsif seconds_ago < 1.week then "#CEDC34"
            elsif seconds_ago < 1.month then "#DCAA24"
            elsif seconds_ago < 1.year then "#C2692A"
            else "#AA2D2F"
            end
    "<span style='color:#{color};font-weight:bold;font-variant:small-caps;'>#{time_ago_in_words(past_time)} ago</span>".html_safe
  end

  def simple_check(checked)
    image_tag("gentleface/16/#{checked ? 'checkbox_checked' : 'checkbox_unchecked'}.png", alt: '', style: 'vertical-align:text-bottom')
  end

  def simple_date(past_date)
    return '' if past_date.blank?
    if past_date == Date.today
      'Today'
    elsif past_date == Date.today - 1.day
      'Yesterday'
    elsif past_date == Date.today + 1.day
      'Tomorrow'
    elsif past_date.year == Date.today.year
      past_date.strftime("%b %d")
    else
      past_date.strftime("%b %d, %Y")
    end
  end

  def simple_time(past_time)
    return '' if past_time.blank?
    if past_time.to_date == Date.today
      past_time.strftime("<b>Today</b> at %I:%M %p %Z").html_safe
    elsif past_time.year == Date.today.year
      past_time.strftime("on %b %d at %I:%M %p %Z")
    else
      past_time.strftime("on %b %d, %Y at %I:%M %p %Z")
    end
  end

  def display_errors(object)
    #MY_LOG.info "ERRORS: #{object.errors.to_yaml} #{object.study_original_results.map{|x| x.errors}.to_yaml}"
    render :partial => "layouts/errors", :locals => {name: object.class.name, errors: object.errors} if object.errors.any?
  end

  def markdown(text)
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, :autolink => true, :space_after_headers => true)
    markdown.render(text).html_safe
  end

  def link_to_add_fields(name, f, association)
    new_object = f.object.send(association).klass.new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      render(association.to_s.singularize + "_fields", f: builder)
    end
    link_to('#', class: "add-links btn btn-success btn-xs", data: {id: id, fields: fields.gsub("\n", "")}) do
      content_tag(:span, '', class: 'glyphicon glyphicon-plus add-links') + content_tag(:span, name)
    end
  end


  # From Contour


  def cancel
    link_to 'Cancel', URI.parse(request.referer.to_s).path.blank? ? root_path : (URI.parse(request.referer.to_s).path), class: 'btn btn-default btn-block'
  end

  def sort_field_helper(order, sort_field, display_name)
    sort_field_order = (order == sort_field) ? "#{sort_field} DESC" : sort_field
    symbol = (order == sort_field) ? '&raquo;' : (order == sort_field + ' DESC' ? '&laquo;' : '&laquo;&raquo;')
    selected_class = (order == sort_field) ? 'selected' : (order == sort_field + ' DESC' ? 'selected' : '')
    content_tag(:span, class: selected_class) do
      display_name.to_s.html_safe + ' ' + link_to(raw(symbol), url_for( params.merge( order: sort_field_order )  ), style: 'text-decoration:none')
    end.html_safe
  end

  # From Twitter-Bootstrap-Rails
  def flash_block
    output = ''
    flash.each do |type, message|
      unless session["user_return_to"] == root_path and I18n.t("devise.failure.unauthenticated") == message
        output += flash_container(type, message) if ['alert', 'notice', 'error', 'warning', 'success', 'info'].include?(type.to_s)
      end
    end

    raw(output)
  end

  # From Twitter-Bootstrap-Rails
  def flash_container(type, message)
    type = 'success' if type.to_s == 'notice'
    type = 'danger' if ['alert', 'error'].include?(type.to_s)

    content_tag(:div, class: "navbar-alert alert alert-#{type}") do
      content_tag(:a, raw("&times;"), href: '#', class: 'close', data: { dismiss: 'alert' }) + message
    end.html_safe
  end

end
