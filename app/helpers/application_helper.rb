module ApplicationHelper
  
  def old_spiffify(text)
    unless text.empty?
      auto_link(textilize(coderay(text).html_safe).html_safe).html_safe
    end
  end
  
  
  def spiffify(text)
    unless text.empty?
      markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, :autolink => true, :space_after_headers => true)
      markdown.render(text).html_safe
    end
  end
  
  def coderay(text)
    text.gsub(/\<code( lang="(.+?)")?\>(.+?)\<\/code\>/m) do
      "\n<notextile>#{CodeRay.scan($3, $2).div(:css => :class).html_safe}</notextile>"
    end
  end
  
  def entry_list(entries)
    entries.collect do |entry| 
      "<li style=\"line-height: 10px;font-size: 11px;\">#{link_to(entry.title, entry)}</li>"
    end.join("\n").html_safe
  end
  
  def textilize(text)
    Textilizer.new(text).to_html unless text.blank?
  end
  
  def clear_code_tags(text)
    if /\<code( lang="(.+?)")?\>(.+?)\<\/code\>/m =~ text
      text.gsub(/\<code( lang="(.+?)")?\>(.+?)\<\/code\>/m) do
        return "<code>#{$3}</code>"
      end
    end
    return text
  end
  
end
