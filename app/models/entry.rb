require 'tinder'
class Entry < ActiveRecord::Base
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  TokenExpiry = 2.weeks

  acts_as_taggable_on :tags
  has_paper_trail

  scope :by_date, order("entries.created_at DESC")
  scope :last_updated, order("entries.updated_at DESC")

  validates_presence_of :title, :content
  
  after_create :notify_after_create
  after_update :notify_after_update
  after_destroy :notify_after_destroy

  def self.internal_search(query)
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
  
  def self.external_search(query)
    "OK" if query.blank?
    response = self.search query
    took = response.took.to_f / 1000
    total = response.results.total

    results = response.results.map { |r| "#{r._source.title}: https://artifact.medivo.io/entries/#{r._id}" }

    top_three = results[0..3]

    stats = ":thought_balloon: Search for #{query}: Elapsed time #{took} seconds for #{total} records"
    top_three.unshift(stats.to_json)
    
    if Rails.env.production?
      room = self.new_fire('notifications')#room name needs to be changed when dev is done...
      top_three.each {|r| room.speak "#{r}"}
      room.paste results.join("\n")
    else
      return results.unshift(stats.to_json).join("\n")
    end
    
    "OK"
  end
  
  private
  
  def self.new_fire(room_name)
    campfire = Tinder::Campfire.new('medivo', { :token => '641ff5dcb2ac49623df07721fa37fb537a95486f', :ssl => true})
    room = campfire.find_room_by_name(room_name)
  end
  
  def campfire_helper(token)
    if Rails.env.production?
      room = self.new_fire('Medivo iTeam')
      room.speak ":bicyclist: [ARTFCT] (https://artifact.medivo.io/entries/#{self.id}) #{token} by #{User.find(self.versions.last.whodunnit).email}, #{self.title}"
    end
  end
  
  def notify_after_create
    campfire_helper("created")
  end
  
  def notify_after_update
    campfire_helper("updated")
  end
  
  def notify_after_destroy
    campfire_helper("destroyed")
  end

end
