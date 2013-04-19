module EntriesHelper
  
  def get_sorted_versions(entry)
    entry.versions.sort_by {|vers| vers.created_at}.reverse.collect do |version|
      if version.object != nil
        "<li><a href=\"/entries/version/#{version.id}\">#{version.id}, #{User.find_by_id(version.whodunnit.to_i).try(:email) || 'ANONYMOUS'} , #{version.created_at.strftime('%a %b %d %Y %H:%M:%S %Z')}, #{version.event}</a> </li>"
      else
        "<li>#{version.id}, #{User.find_by_id(version.whodunnit.to_i).try(:email) || 'ANONYMOUS'} , #{version.created_at.strftime('%a %b %d %Y %H:%M:%S %Z')}, #{version.event}</li>"
      end
    end.join.html_safe
  end
  
  def pretty_duration(duration)
    ChronicDuration.output(duration, :units => 2, :format => :short)
  end

  def access_token_status(entry)
    content_tag :span, :class => 'access-token' do
      case
      when entry.access_token.blank?
        'no access token | ' + link_to('create', set_token_entry_path(entry), :method => :post)
      when entry.valid_access_token?(entry.access_token)
        link_to('token', entry_path(entry,:token => entry.access_token)) +
          ' expires in ' + pretty_duration(entry.access_token_expires_at - Time.zone.now) + ' | ' +
          link_to('remove', remove_token_entry_path(entry), :method => :delete)
      else
        'token expired ' + pretty_duration(Time.zone.now - entry.access_token_expires_at) + ' ago | ' +
          link_to('reset', set_token_entry_path(entry), :method => :post)
      end.html_safe
    end
  end

end
