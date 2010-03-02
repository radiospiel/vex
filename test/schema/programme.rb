create_table "programmes", :force => true do |t|
  t.integer  "programme_group_id"
  t.string   "title",                                         :default => "",       :null => false
  t.string   "sub_title",                                     :default => "",       :null => false
end
