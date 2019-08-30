class AddBalcklistToDriver < ActiveRecord::Migration[5.0]
 def up
    change_column_default :drivers, :blacklisted, false
  end

  def down
    change_column_default :drivers, :blacklisted, true
  end
end
