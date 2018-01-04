class Nokogiri::XML::Node
  def add_css_class( *classes )
    existing = (self['class'] || "").split(/\s+/)
    self['class'] = existing.concat(classes).uniq.join(" ")
    self
  end
end

ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
  html = %(<div class="field_with_errors">#{html_tag}</div>).html_safe
  # add nokogiri gem to Gemfile

  form_fields = [
    'textarea',
    'input',
    'select'
  ]

  elements = Nokogiri::HTML::DocumentFragment.parse(html_tag).css "label, " + form_fields.join(', ')

  elements.each do |e|
    if e.node_name.eql? 'label'
      html = %(#{e.add_css_class('error')}).html_safe
    elsif form_fields.include? e.node_name
      html = %(#{e.add_css_class('error')}).html_safe
    end
  end
  html
end
