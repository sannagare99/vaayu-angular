class AddRcBookDocToVehicle < ActiveRecord::Migration[5.0]
  def up
    add_attachment :vehicles, :rc_book_doc
  end
  def down
    remove_attachment :vehicles, :rc_book_doc
  end
end
