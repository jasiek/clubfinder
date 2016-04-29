class CreateClubs < ActiveRecord::Migration[5.0]
  def change
    create_table :clubs do |t|
      t.string :iaru_region
      t.string :country
      t.string :callsign
      t.string :name
      t.string :website
      t.string :email
      t.string :phone
      t.point :location
      t.timestamps
    end
  end
end
