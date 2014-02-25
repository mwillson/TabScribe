class TabTranslator

  @queue = :tabs_queue

  def self.perform(stab_id)
    stab = STab.find(stab_id)
    base_url = "http://tabs.ultimate-guitar.com"
    user_agent = "Mozilla/4.0 (Compatible; MSIE 6.1; Windows XP; .NET CLR 1.1.4322; .NET CLR 2.0.50727)"
    stab.update_attribute(:name, "Scribed Tab #{stab_id}")
    doc =  Nokogiri::HTML(open(stab.original_url))
    print_url = doc.css('a.pr_b').first["href"]
    doc = Nokogiri::HTML(open(base_url + print_url, "User-Agent" => user_agent, "Referer" => stab.original_url))
    stab.update_attribute(:contents,  doc.css('pre').first.text)
  end

end
