
class Hash
  def inspect
    "{" + to_a.sort_by do |k, v|
      k.to_s
    end.map do |k,v| 
      "#{k.inspect} => #{v.inspect}" 
    end.join(", ") + "}"
  end
end

module Hash::Etest
  def test_inspect
    h = {"b" => 2, :a => 2}
    assert_equal('{:a => 2, "b" => 2}', h.inspect)
  end
end if VEX_TEST == "base"