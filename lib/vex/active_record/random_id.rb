module ActiveRecord::RandomID
  module Generator
    def self.string
      # This puts 40 random bits into a string.
      ActiveSupport::SecureRandom.random_number(0xffffffffff).to_s(36)
    end

    def self.integer
      # This gives us 31 bits of random data.
      ActiveSupport::SecureRandom.random_number 0x7fffffff
    end

    def self.large
      # This gives us 63 bits of random data.
      ActiveSupport::SecureRandom.random_number 0x7fffffffffffffff
    end
  end
  
  def with_random_column(column, generator = :integer)
    before_validation do |rec|
      next if rec.send(column)
      rec.send "#{column}=", ActiveRecord::RandomID::Generator.send(generator)
    end
  end
  
  def with_random_id(generator = :integer)
    with_random_column primary_key, generator
  end
end

class ActiveRecord::Base
  extend ActiveRecord::RandomID
end

module ActiveRecord::RandomID::Etest
  class RandomBase < ActiveRecord::Base
    lite_table do
      text :parameters
    end

    with_random_id
  end

  def test_random_id
    rb = RandomBase.create!
    uids = [ rb.id ]
    rb.save
    uids << rb.id
    
    rb.reload
    uids << rb.id

    assert_not_nil(rb.id)
    assert_equal([ rb.id ], uids.uniq)
  end
end
