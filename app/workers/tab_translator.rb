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
    linearray = doc.css('pre').first.text.split("\r\n")
    staves = find_staves(linearray).inspect
    stab.update_attribute(:contents, staves)
  end

  def find_staves(tabfile)
    keys = []
    bars = []
    lines = []
    num_guitar_strings = 6
    # regex to find guitar strings
    raw_string_regex = /^\w[\|\d\w\-\u2014\s\~\+\.\(\/\\\^\>]*\|$/
    # regex to find notes/'augmented' notes
    raw_note_regex = /([\w\d]+)/
    tabfile.each do |line|
      if line.strip.scan(raw_string_regex) != []
        lines.push(line)
        processed_line = []
        key = line[0]
        keys.push(key)
        matches(line[1..-1], raw_note_regex).each do |note|
          # each 'note' is of type MatchData
          # processed line becomes an array of arrays which represent notes 
          notearray = [note.begin(0), note.end(0), note.to_s, key]
          processed_line.push(notearray)
        end
        bars.push(processed_line)
      end
    end
    # 6 is the number of guitar strings (make this more dynamic later)
    thingy = chunks(bars, num_guitar_strings)
    thingy
  end

  # create array of successive n sized chunks from l
  # 'l' is the list of line 'tuples'

  def chunks(l, n)
    chunks = []
    l.each_with_index do |line, i|
      if ((i+1) % n) == 0
        # push the n previous lines (as its own array) onto chunks
        chunks.push( l[(i+1-n)..i] ) 
      end
    end
    chunks
  end

  # matches (string s, regular expression re) 
  #
  # returns a list of MatchData objects to use in find_staves
  # each MatchData object is a 'note' from a line that we can get useful 
  # data from, like its beginning and ending index

  def matches(s, re)
    start_at = 0
    matches = []
    while(m = s.match(re, start_at))
      matches.push(m)
      start_at = m.end(0)
    end
    matches
  end

end
