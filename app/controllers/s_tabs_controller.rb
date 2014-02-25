class STabsController < ApplicationController
  def new
    @stab = STab.new
  end

  def show
    @stab = STab.find(params[:id])
  end

  def create
    @stab = STab.new(stab_params)
  end

private

  # generate a params hash for a newly created  s_tab
  def stab_params
    hash = params[:s_tab]
    hash[:name] = "Thingy"
    hash[:contents] = "|---2-3-4---|"
    hash
  end

end
