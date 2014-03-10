class TabTranslator

  @queue = :tabs_queue

  # this gets called from stabs_controller, 'create' method

  def self.perform(stab_id)
    stab = STab.find(stab_id)
    doctext = Scraper.new.scrape(stab)
    stab.update_attribute(:name, "Scribed Tab #{stab_id}")
    parser = TabParser.new
    staves = parser.find_staves(doctext.split("\r\n"))
    stab.update_attribute(:contents, staves.inspect)
    tabs = []
    staves.each do |staff|
      tabs.push(parser.find_intersections(staff))
    end

  end

end
