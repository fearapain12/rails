class CreatePeople < ActiveRecord::Migration
  def up
    # Create table 'locations'
    # Since there is no specific type for 'double', we use :limit => 53,
    # this limit value corresponds to the precision of the column in bits
    create_table :people do |t|

      t.string 'name'
      t.timestamps
    end
  end

  def down
    # Delete table 'locations' and all its content
    drop_table 'people'
  end
end
