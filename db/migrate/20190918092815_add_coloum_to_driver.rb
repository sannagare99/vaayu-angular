class AddColoumToDriver < ActiveRecord::Migration[5.0]
  def up
  	add_attachment :drivers, :police_verification_vailidty_doc
  	add_attachment :drivers, :sexual_policy_doc
  	add_attachment :drivers, :medically_certified_doc
  	add_attachment :drivers, :bgc_doc
  end

  def down
  	remove_attachment :drivers, :police_verification_vailidty_doc
  	remove_attachment :drivers, :sexual_policy_doc
  	remove_attachment :drivers, :medically_certified_doc
  	remove_attachment :drivers, :bgc_doc
  end
end
