create_table "belongings", :force => true do |t|
  t.string    "name"
  t.string    "having_ids"
end

create_table "havings", :force => true do |t|
  t.string   "name"
end


create_table "belongings_havings", :force => true, :id => false do |t|
  t.integer   "having_id"
  t.integer   "belonging_id"  
end

(1..20).each do |idx|
  Having.create! :name => "#{idx}"
end
