module File::Grep
  
  def grep(rex, *files)
    files = files.flatten
    
    unless block_given?
      results = []
      grep(rex, files) do |line, file, *args|
        results << [ line, file ]
      end
      return results
    end
    
    files.each do |file|
      File.readlines(file).each do |line|
        next unless matches = (rex.match(line))
        yield line, file, matches 
      end
    end
  end
end

module File::Grep::Etest
  def test_grep
    assert_equal 4, File.grep(/Etest/, __FILE__).length
    assert_equal 5, File.grep(/ETEST/i, __FILE__).length
  end
  
  def test_greps
    assert_equal 8, File.grep(/Etest/, [ __FILE__, __FILE__ ]).length
    assert_equal 8, File.grep(/Etest/, __FILE__, __FILE__ ).length
  end
end
