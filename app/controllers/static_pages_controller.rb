class StaticPagesController < ApplicationController
  def home
    @stab = STab.new
  end

  def help
  end

  def about
  end
end
