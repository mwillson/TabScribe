class Scraper

  def scrape(stab)
    base_url = "http://tabs.ultimate-guitar.com"
    user_agent = "Mozilla/4.0 (Compatible; MSIE 6.1; Windows XP; .NET CLR 1.1.4322; .NET CLR 2.0.50727)"
    doc =  Nokogiri::HTML(open(stab.original_url))
    print_url = doc.css('a.pr_b').first["href"]
    doc = Nokogiri::HTML(open(base_url + print_url, "User-Agent" => user_agent, "Referer" => stab.original_url))
    doc.css('pre').first.text
  end

end
