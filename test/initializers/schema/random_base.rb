class Url < ActiveRecord::Base
  lite_table do
    string :category
    text :url
    integer :random_base_id
  end
end

class RandomBase < ActiveRecord::Base
  lite_table do
    text :parameters
  end

  with_random_id
end
