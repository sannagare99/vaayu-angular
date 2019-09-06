class AddIdProofDocToDriver < ActiveRecord::Migration[5.0]
  def up
    add_attachment :drivers, :id_proof_doc
  end
  def down
    remove_attachment :drivers, :id_proof_doc
  end
end
