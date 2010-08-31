module ActiveRecord::Extension::CachedColumn::Etest
  def setup
    require "timecop"
  end
    
  class X < ActiveRecord::Base
    lite_table do 
      string :something
      string :bigger
      string :bigger_w_param
    end

    cached_column :something do
      $something = $something + 1
      "something-big"
    end

    cached_column :bigger, :time_to_live => 1.day do
      $something = $something + 1
      "something-bigger"
    end

    cached_column :bigger_w_param do |rec|
      rec.class.name
    end
  end
  
  def test_something
    $something = 0
    x = X.create!
    assert_equal(0, $something)
    assert_equal("something-big", x.something)
    assert_equal(1, $something)
    assert_equal("something-big", x.something)
    assert_equal(1, $something)

    Timecop.travel(360.seconds) do
      assert_equal(1, $something)
      assert_equal("something-big", x.something)
      assert_equal(2, $something)
    end
  end

  def test_w_new_record
    $something = 0
    x = X.new
    assert_equal(0, $something)
    assert_equal("something-big", x.something)
    assert_equal(1, $something)
    assert_equal("something-big", x.something)
    assert_equal(1, $something)

    Timecop.travel(360.seconds) do
      assert_equal(1, $something)
      assert_equal("something-big", x.something)
      assert_equal(2, $something)
    end
  end
  
  def test_time_to_live
    $something = 0
    x = X.create!
    assert_equal(0, $something)
    assert_equal("something-bigger", x.bigger)
    assert_equal(1, $something)

    Timecop.travel(Time.now + 6.minutes) do
      assert_equal(1, $something)
      assert_equal("something-bigger", x.bigger)
      assert_equal(1, $something)
    end

    Timecop.travel(Time.now + 25.hours) do
      assert_equal(1, $something)
      assert_equal("something-bigger", x.bigger)
      assert_equal(2, $something)
    end
  end

  
  def test_bigger_w_params
    $something = 0
    x = X.create!
    assert_equal("ActiveRecord::Extension::CachedColumn::Etest::X", x.bigger_w_param)
  end
end
