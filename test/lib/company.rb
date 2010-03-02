class Company < ActiveRecord::Base
  has_many :users
  
  has_a_task do
    { :worker => "cron", :owner => managers.first }
  end

  def logger
    ActiveRecord::Base.logger
  end
  
  def managers
    [ users.first ]
  end
end
