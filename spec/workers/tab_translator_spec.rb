require 'spec_helper'

describe TabTranslator do

    line = [[1,1,3,"e"],[2,2,4,"e"],[3,3,5,"e"]]
    tt = TabTranslator.new

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
    lines = []
    i = 0
    while i < 6
      lines.push([[3,4,"2","e"],[5,6,"3","e"],[7,8,"3","e"],[12,13,"5","e"],[14,15,"6","e"]])
      i += 1
    end
    to_check = []
    to_check.push(lines)
    expect(staves2).to eq(to_check)
  end

end
