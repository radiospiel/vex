module ArExt
end

module ArExt::Etest
  def test_validation
    #assert_valid    Feed.new, :id 
    #assert_invalid  Feed.new(:keyword => "me"), :keyword
    #assert_invalid  Feed.new, :keyword
    #assert_valid    Feed.new(:keyword => "sme"), :keyword
  end

  def test_each
    Feed.delete_all
    
    range = 1..12
    expected = []
    range.each do |id|
      feed = Feed.create! :keyword => "keyword-#{id}"
      expected << feed.keyword
    end

    keywords = []
    
    Feed.each(:batch_size => 5) do |feed|
      keywords << feed.keyword
    end

    assert_equal(expected.sort, keywords.sort)
  end

  def test_each_with_progress
    Feed.delete_all
    
    range = 1..12

    expected = []
    range.each do |id|
      feed = Feed.create! :keyword => "keyword-#{id}"
      expected << feed.keyword
    end

    keywords = []
    
    count = 0
    
    Feed.with_progress.each(:batch_size => 5) do |feed|
      count += 1
      keywords << feed.keyword
    end
    
    assert_equal(12, count)

    assert_equal(expected.sort, keywords.sort)
  end

  def test_find_by_extension
    Feed.delete_all

    krange = 1..3
    trange = 1..3

    krange.each do |k|
      trange.each do |t|
        Feed.create! :keyword => "key-#{k}", :language => "language-#{t}"
      end
    end

    # --- test find_all_by ------------
    
    assert 3, Feed.find_all_by(:keyword => "key-1").length
    assert 3, Feed.find_all_by(:language => "language-1").length
    assert 1, Feed.find_all_by(:keyword => "key-1", :language => "language-1").length

    assert 0, Feed.find_all_by({:keyword => "key-1"}, :conditions => "0 == 1").length
    assert 0, Feed.find_all_by({:language => "language-1"}, :conditions => "0 == 1").length
    assert 0, Feed.find_all_by({:keyword => "key-1", :language => "language-1"}, :conditions => "0 == 1").length

    # --- test find_by ------------
    
    assert "key-1", Feed.find_by(:keyword => "key-1").keyword
    
    assert "key-1", Feed.find_by(:keyword => "key-1", :language => "language-1").keyword
    assert "language-1", Feed.find_by(:language => "language-1").language
    assert_nil Feed.find_by(:keyword => "key-00")
    
    assert_nil Feed.find_by({:keyword => "key-1"}, :conditions => "0 == 1")
    assert_nil Feed.find_by({:keyword => "key-1", :language => "language-1"}, :conditions => "0 == 1")
    assert_nil Feed.find_by({:language => "language-1"}, :conditions => "0 == 1")
  end

  def test_find_or_create_by_extension
    Feed.delete_all

    krange, trange = 1..2, 1..2

    krange.each do |k|
      trange.each do |t|
        data = { :keyword => "key-#{k}", :language => "language-#{t}" }

        feed = Feed.find_or_create_by(data)
        assert_equal(data[:keyword], feed.keyword)
        assert_equal(data[:language], feed.language)
      end
    end

    # The next time they should not be recreated
    current_count = Feed.count
    
    krange.each do |k|
      trange.each do |t|
        data = { :keyword => "key-#{k}", :language => "language-#{t}" }

        feed = Feed.find_or_create_by(data)
        assert_equal(data[:keyword], feed.keyword)
        assert_equal(data[:language], feed.language)
      end
    end

    assert_equal(current_count, Feed.count)
  end

  def test_find_or_create_by_extension_with_options
    Feed.delete_all

    krange, trange = 1..2, 1..2

    krange.each do |k|
      trange.each do |t|
        data = { :keyword => "key-#{k}", :language => "language-#{t}" }

        feed = Feed.find_or_create_by(data, :data => "first")

        assert "first", feed.data
        assert "first", feed.reload.data
      end
    end

    assert_equal(4, Feed.count)

    krange.each do |k|
      trange.each do |t|
        data = { :keyword => "key-#{k}", :language => "language-#{t}" }

        feed = Feed.find_or_create_by(data, :data => "second")

        assert "first", feed.data
        assert "first", feed.reload.data
      end
    end

    assert_equal(4, Feed.count)
  end

  def test_find_or_create_by_extension_with_callback
    Feed.delete_all

    krange, trange = 1..2, 1..2

    krange.each do |k|
      trange.each do |t|
        data = { :keyword => "key-#{k}", :language => "language-#{t}" }

        feed = Feed.find_or_create_by(data) do 
          { :data => "first" }
        end
        
        assert "first", feed.data
        assert "first", feed.reload.data
      end
    end

    assert_equal(4, Feed.count)

    krange.each do |k|
      trange.each do |t|
        data = { :keyword => "key-#{k}", :language => "language-#{t}" }

        feed = Feed.find_or_create_by(data, :data => "second")

        assert "first", feed.data
        assert "first", feed.reload.data
      end
    end

    assert_equal(4, Feed.count)
  end

  def test_find_or_create_all_by_extension
    Feed.delete_all

    krange = 1..2
    trange = 1..2

    keywords = krange.map do |k| "key-#{k}" end
    languages = trange.map do |k| "language-#{k}" end

    feeds = Feed.find_or_create_all_by(:keyword => keywords, :language => languages)

    assert_equal(4, Feed.count)
    assert_equal(4, feeds.count)
    assert_equal(%w(key-1 key-1 key-2 key-2), feeds.map(&:keyword).sort)
    assert_equal(%w(key-1 key-2), feeds.map(&:keyword).uniq.sort)
    assert_equal(4, feeds.map do |feed| "#{feed.keyword}-#{feed.language}" end.uniq.count)


    feeds = Feed.find_or_create_all_by({ :keyword => keywords, :language => languages })

    assert_equal(4, Feed.count)
    assert_equal(4, feeds.count)
    assert_equal(%w(key-1 key-1 key-2 key-2), feeds.map(&:keyword).sort)
    assert_equal(%w(key-1 key-2), feeds.map(&:keyword).uniq.sort)
    assert_equal(4, feeds.map do |feed| "#{feed.keyword}-#{feed.language}" end.uniq.count)
  end

  def test_find_or_create_all_by_extension_w_data
    Feed.delete_all

    krange = 1..2
    trange = 1..2

    keywords = krange.map do |k| "key-#{k}" end
    languages = trange.map do |k| "language-#{k}" end

    feeds = Feed.find_or_create_all_by({ :keyword => keywords, :language => languages }, :data => "first")

    assert_equal(4, Feed.count)
    assert_equal(4, feeds.count)
    assert_equal(%w(first), feeds.map(&:data).uniq)
   
    feeds = Feed.find_or_create_all_by({ :keyword => keywords, :language => languages }, :data => "second")

    assert_equal(4, Feed.count)
    assert_equal(4, feeds.count)
    assert_equal(%w(first), feeds.map(&:data).uniq)
  end
end
