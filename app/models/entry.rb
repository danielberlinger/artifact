class Entry < ActiveRecord::Base

  TokenExpiry = 2.weeks

  acts_as_taggable_on :tags
  has_paper_trail

  scope :by_date, order("entries.created_at DESC")
  scope :last_updated, order("entries.updated_at DESC")

  validates_presence_of :title, :content


  def self.search(query)
    unless query.to_s.strip.empty?
      tokens = query.split(/ |\+|,/).collect {|c| "%#{c.downcase}%"}
      results = find_by_sql(["select s.* from entries s where #{ (["(lower(s.title) like ? or lower(s.content) like ?)"] *
                    tokens.size).join(" and ") } order by s.created_at desc", *(tokens * 2).sort])
      #tag search
      results << self.tagged_with(query.split((/ |\+|,/)), :any => :true)
      results.flatten!.uniq!

      #if a skip tag has been added to an entry, remove it form the search results
      skipped = results.collect do |entry|
        entry if entry.tag_list.count do |t|
           t =='skip'
        end == 0
      end.compact
      {:full => results, :skipped => skipped}
    else
      {:full => [], :skipped => []}
    end
  end

  def self.authorize_by_token(id,token)
    e = find_by_id(id)
    e && e.valid_access_token?(token)
  end

  def valid_access_token?(token)
    token.present? and token == access_token and Time.zone.now < access_token_expires_at
  end

  def set_token
    # Using this to avoid unnecessary versions/timestamp updates
    self.class.update_all({:access_token => SecureRandom.hex(48), :access_token_expires_at => TokenExpiry.from_now}, {:id => id})
  end

  def remove_token
    # Using this to avoid unnecessary versions/timestamp updates
    self.class.update_all({:access_token => nil, :access_token_expires_at => nil}, {:id => id})
  end

end
