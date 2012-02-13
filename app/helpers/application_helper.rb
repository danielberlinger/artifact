module ApplicationHelper
  
  def spiffify(text)
    unless text.empty?
      auto_link(textilize(coderay(text).html_safe).html_safe).html_safe
    end
  end
  
  def coderay(text)
    text.gsub(/\<code( lang="(.+?)")?\>(.+?)\<\/code\>/m) do
      "\n<notextile>#{CodeRay.scan($3, $2).div(:css => :class).html_safe}</notextile>"
    end
  end
  
  def entry_list(entries)
    entries.collect do |entry| 
      "<li>#{link_to(entry.title, entry)}</li>"
    end.join("\n").html_safe
  end
  
  def textilize(text)
    Textilizer.new(text).to_html unless text.blank?
  end
  
end
