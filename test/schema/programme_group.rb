create_table "programme_groups", :force => true do |t|
  t.string   "title",          :default => "", :null => false
  t.string   "sub_title",      :default => "", :null => false
  t.text     "synopsis",                       :null => false
  t.datetime "created_at"
  t.datetime "updated_at"
  t.integer  "user_id"
  t.integer  "company_id"
  t.integer  "no_of_episodes"
end

add_index "programme_groups", ["company_id", "title"], :name => "index_programme_groups_on_company_id_and_title", :unique => true
