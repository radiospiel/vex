class User < ActiveRecord::Base
  belongs_to :company
  
  validates_presence_of :company
  
  def self.admins
    all(:limit => 1)
  end
end
