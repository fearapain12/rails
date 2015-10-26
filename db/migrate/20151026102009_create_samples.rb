class CreateSamples < ActiveRecord::Migration
  def up
    # Create table 'locations'
    # Since there is no specific type for 'double', we use :limit => 53,
    # this limit value corresponds to the precision of the column in bits
    create_table :samples do |t|

      t.float 'latitude'
      t.float 'longitude'
      t.float 'timestamp'
      t.integer 'person_id'
      t.timestamps
    end
  end

  def down
    # Delete table 'locations' and all its content
    drop_table 'samples'
  end
end
