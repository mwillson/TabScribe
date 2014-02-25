class STabsController < ApplicationController

  require 'open-uri'

  def new
    @stab = STab.new
  end

  def show
    @stab = STab.find(params[:id])
  end

  def create
    @stab = STab.new(stab_params)
    if @stab.save
      redirect_to @stab
    else
      render 'new'
    end
  end

private

  # generate a params hash for a newly created  s_tab
  def stab_params

    base_url = "http://tabs.ultimate-guitar.com"
    user_agent = "Mozilla/4.0 (Compatible; MSIE 6.1; Windows XP; .NET CLR 1.1.4322; .NET CLR 2.0.50727)"
    hash = params[:s_tab]
    hash[:name] = "Thingy"
    doc =  Nokogiri::HTML(open(hash[:original_url]))
    print_url = doc.css('a.pr_b').first["href"]
    doc2 = Nokogiri::HTML(open(base_url + print_url, "User-Agent" => user_agent, "Referer" => hash[:original_url]))
    hash[:contents] = doc2.css('pre').first.text
    hash
  end

end
