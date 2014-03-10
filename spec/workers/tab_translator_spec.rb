require 'spec_helper'

describe TabTranslator do

    line = [[1,1,3,"e"],[2,2,4,"e"],[3,3,5,"e"]]
    tt = TabParser.new

    i = 0
    lines = []
    while i < 6
      lines.push(line)
      i += 1
    end

  it "should yield chunks correctly" do
    staves = tt.chunks(lines, 2)
    expect(staves).to  eq([ [[[1,1,3,"e"],[2,2,4,"e"],[3,3,5,"e"]] , [[1,1,3,"e"],[2,2,4,"e"],[3,3,5,"e"]]], 
    [[[1,1,3,"e"],[2,2,4,"e"],[3,3,5,"e"]] , [[1,1,3,"e"],[2,2,4,"e"],[3,3,5,"e"]]],
    [[[1,1,3,"e"],[2,2,4,"e"],[3,3,5,"e"]] , [[1,1,3,"e"],[2,2,4,"e"],[3,3,5,"e"]]] ])
  end

  it "find_staves should give back the matching groups of lines in array form" do
    bar = "e|--2-3-3----5-6--|"
    example = ["some tab by someone", "by some artist", "e|--2-3-3----5-6--|", "here's some more text"]
    i = 0
    while i < 5
      example.push(bar)
      i += 1
    end
    staves2 = tt.find_staves(example)
    lines2 = []
    i = 0
    while i < 6
      lines2.push([[3,4,"2","e"],[5,6,"3","e"],[7,8,"3","e"],[12,13,"5","e"],[14,15,"6","e"]])
      i += 1
    end
    to_check = []
    to_check.push(lines2)
    expect(staves2).to eq(to_check)
  end

  it "find intersections should give back a list of columns" do
    staff = [ [[1,1,3,"e"],[2,2,4,"e"],[4,4,5,"e"]],[[1,1,6,"A"],[3,3,7,"A"],[4,4,8,"A"]] ]
    expect(tt.find_intersections(staff)).to eq([ [["e",3],["A",6]],[["e",5],["A",8]] ])
  end

end
