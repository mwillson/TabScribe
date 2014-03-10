class TabParser

  # creates and returns an array of arrays(staves) of lines (which are 2D arrays themselves)
  # IT'S A 4D ARRAY OMG

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

  ### ----- END OF FIND_STAVES ROUTINES --- ###
  
  def find_intersections(staff)
    intersections = {}
 
    # don't worry about the last (lowest) line of the staff, since there is nothing to 
    # compare it to
    for line in 0..(staff.length-1)
      for noteplace in 0..(staff[line].length-1)
        note_a = staff[line][noteplace]
        
        for l in staff[(line+1)..-1]
          to_remove = []
          for note_b in l
            if intersection(note_a, note_b)
              if intersections[note_a].nil?
                intersections[note_a] = []
              end
              intersections[note_a].push(note_b)
              to_remove.push(note_b)
            end
          end
          to_remove.each do |rnote|
            l.delete(rnote)
          end
        end
      end
    end

    columns = []
    sorted_keys = intersections.keys.sort
    sorted_keys.each do |key|
      column = []
      # a thing in column should look like ["3","e"] or ["5","A"]
      # the info contained is the fret and the line it's on('string')
      column.push([key[3],key[2]])
      intersections[key].each do |k|
        column.push([k[3],k[2]])
      end
      # so, columns will contain things like [["3","e"],["3","A"]["5","B"]["5","G"]]
      columns.push(column)
    end
    columns

  end

  # Determine if two ranges of integers intersect.
 
  def intersection(note_a, note_b)

    return (note_a[0] <= note_b[1] and note_a[1] >= note_b[0])

  end

end
