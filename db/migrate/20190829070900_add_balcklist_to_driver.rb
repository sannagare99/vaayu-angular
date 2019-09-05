class AddBalcklistToDriver < ActiveRecord::Migration[5.0]
 def up
    change_column_default :drivers, :blacklisted, false rescue nil
  end

  def down
    change_column_default :drivers, :blacklisted, true rescue nil
  end
end
