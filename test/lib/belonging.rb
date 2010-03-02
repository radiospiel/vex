class Belonging < ActiveRecord::Base
  belongs_to_many :havings,
    :supersedes => lambda { |name|
      has_and_belongs_to_many name, :join_table => :belongings_havings, :class_name => "Having"
    }
end
