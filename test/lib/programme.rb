class Programme < ActiveRecord::Base
  belongs_to :programme_group
  
  # has_view :programmes_counter, "SELECT programme_group_id, MAX(episode_no) AS count_all FROM programmes GROUP BY programme_group_id"
end
