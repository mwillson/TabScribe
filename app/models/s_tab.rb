class STab < ActiveRecord::Base
  attr_accessible :contents, :name, :original_url

  validates(:name, presence: true)
  validates(:contents, presence: true)
  validates(:original_url, presence: true)
end
