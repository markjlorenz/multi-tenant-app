# 21-Feb-2011 - Mark J. Lorenz - Dapple Before Dawn ltd.
# This file mirrors `db/schema.rb` only put in here what want to be in your migrations for a new tenant

ActiveRecord::Schema.define(:version => 20110218033429) do

  create_table "dogs", :force => true do |t|
    t.string   "name"
    t.string   "size"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
