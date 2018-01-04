require 'redcarpet'
require 'redcarpet/render_strip'

module ApplicationHelper
  def platform_timestamp(dt)
    now = Time.now
    if !dt.nil?
      if now.year != dt.year
        return dt.strftime("%b %e %Y")
      elsif now-1.hour < dt
        diff = ((now - dt) / 1.minute).round
        return diff > 1 ?  diff.to_s + " minutes ago" : "1 minute ago"
      elsif now-24.hour < dt
        diff = ((now - dt) / 1.hour).round
        return diff > 1 ?  diff.to_s + " hours ago" : "1 hour ago"
      elsif now-7.day < dt
        diff = ((now - dt) / 1.day).round
        return diff > 1 ?  diff.to_s + " days ago" : "1 day ago"
      else
        return dt.strftime("%b %e")
      end
    end
  end

  def render_markdown_content(content, options = {})
    return unless content

    options.reverse_merge!({
      target: nil,
      stripdown: false
    })

    if options[:truncate_length].present?
      content = truncate(content, length: options[:truncate_length])
    end

    if options[:target]
      html_render = Redcarpet::Markdown.new(
        Redcarpet::Render::HTML.new(
          hard_wrap: true,
          link_attributes: { target: options[:target] }
        ),
        autolink: true,
        fenced_code_blocks: true,
        highlight: true,
        space_after_headers: true,
        strikethrough: true,
        tables: true,
        underline: true,
        qoute: true,
      )

      html_render.render(content).html_safe
    elsif options[:stripdown]
      content.gsub!(/\!\[([^\]]+)\]?\((https|http)?:\/\/[\S]+\)/, '')
      stripdown = Redcarpet::Markdown.new(Redcarpet::Render::StripDown)
      stripdown.render(content).html_safe
    else
      MarkItZero::Markdown.to_html(content).html_safe
    end
  end

  def report_link(reportable, report_parent = nil, options = {})
    options.reverse_merge!( remote: true, class: 'report-link')

    link_to 'Report', new_report_content_path(
      reportable_id: reportable.id,
      reportable_type: reportable.class.name,
      report_parent_type: report_parent&.class&.name,
      report_parent_id: report_parent&.id
    ), options
  end

  def reportable_url(reportable, report_parent = nil, options = {})
    options.reverse_merge!({ anchor: nil })

    @url ||=
      case reportable.class.name.to_s
      when 'Post'
        post_url(reportable, options)
      when 'Reply'
        return '' unless report_parent.present?
        reportable_url(report_parent, nil, anchor: "#reply_content_#{reportable.id}")
      when 'UserPublication'
        user_publication_url(reportable, options)
      else
        '#'
      end
  end

  def report_source(reportable)
    case reportable.class.name.to_s
    when 'Reply'
      reportable.content
    when 'Post' || 'UserPublication'
      reportable.title
    else
      ''
    end
  end

  def render_error(errors, options = {})
    if errors.present?
      capture do
        content_tag :div, class: "error-help-block" do
          errors.is_a?(Array) ? simple_format(errors.join(", ")) : simple_format(errors)
        end
      end
    end
  end

  def remotipart_render(template, options = {})
    if remotipart_submitted?
      "#{render(template, options)}"
    else
      render(template, options)
    end
  end
end
