module ApplicationHelper
  def subdomain?
    request.subdomain.present? && request.subdomain.eql?("admin")
  end

  def parse_errors(errors)
    messages = errors.full_messages.map { |msg| content_tag(:li, msg) }.join
    html = <<-HTML
    <div class="alert alert-dismissable alert-danger"> 
      <button type="button"class="close" data-dismiss="alert" aria-hidden="true">&times;</button>
      #{messages}
    </div>
    HTML

    html.html_safe
  end

  def close_info
    !session[:close_info].nil?
  end
end
