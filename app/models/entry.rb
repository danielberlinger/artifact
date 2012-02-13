class Entry < ActiveRecord::Base
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
end
