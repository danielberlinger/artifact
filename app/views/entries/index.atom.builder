atom_feed do |feed|
  feed.title "Artifact"
  feed.updated((@entries.first.created_at))
  
  for post in @entries
    feed.entry(post) do |entry|
      entry.title(post.title)
      entry.content(post.content, :type => 'html')
      entry.author(post.versions.last.nil? ? "Digital Developers" : User.find(post.versions.last.whodunnit.to_i).email)
      end
  end
end

