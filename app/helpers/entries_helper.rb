module EntriesHelper
  
  def get_sorted_versions(entry)
    entry.versions.sort_by {|vers| vers.created_at}.reverse.collect do |version|
      if version.object != nil
        "<li><a href=\"/entries/version/#{version.id}\">#{version.id}, #{User.find(version.whodunnit.to_i).email} , #{version.created_at.strftime('%a %b %d %Y %H:%M:%S %Z')}, #{version.event}</a> </li>"
      else
        "<li>#{version.id}, #{User.find(version.whodunnit.to_i).email} , #{version.created_at.strftime('%a %b %d %Y %H:%M:%S %Z')}, #{version.event}</li>"
      end
    end.join.html_safe

  end
  
end
