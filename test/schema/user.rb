create_table "users", :force => true do |t|
  t.string   "email"
  t.string   "crypted_password",           :limit => 40
  t.string   "salt",                       :limit => 40
  t.datetime "created_at"
  t.datetime "updated_at"
  t.string   "remember_token"
  t.datetime "remember_token_expires_at"
  t.text     "preferences"
  t.integer  "company_id"
  t.string   "zip_code",                                  :default => "",   :null => false
  t.string   "street",                                    :default => "",   :null => false
  t.string   "city",                                      :default => "",   :null => false
  t.string   "firstname",                                 :default => "",   :null => false
  t.string   "lastname"
  t.string   "function",                                  :default => "",   :null => false
  t.string   "phone",                                     :default => "",   :null => false
  t.string   "mobile",                                    :default => "",   :null => false
  t.string   "fax",                                       :default => "",   :null => false
  t.date     "birthday"
  t.string   "department",                                :default => "",   :null => false
  t.string   "salutation",                                :default => "",   :null => false
  t.string   "middlename",                                :default => "",   :null => false
  t.string   "state",                                     :default => "",   :null => false
  t.datetime "last_login"
  t.boolean  "newsletter_subscribed",                     :default => true, :null => false
  t.string   "reset_token",                :limit => 100
  t.integer  "failed_logins",                             :default => 0,    :null => false
  t.string   "locale_code"
  t.integer  "country_id"
  t.datetime "privacy_policy_accepted_at"
  t.datetime "previous_login"
end
