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
    text :hashed_attributes
  end

  with_random_id
  serialize_hash :parameters

  hashed_attributes :ha1, :ha2
  
  associated_hash :urls, :keys => "category", :values => "url"
end
