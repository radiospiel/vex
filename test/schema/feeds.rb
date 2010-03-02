create_table "feeds", :force => true do |t|
  t.datetime "created_at"
  t.datetime "updated_at"
  t.string   "type"
  t.string   "keyword"
  t.datetime "refreshed_at"
  t.string   "language"
  t.string   "data"
end
