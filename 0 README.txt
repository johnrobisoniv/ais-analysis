Documentation of all functions / scripts in this folder.
Scripts written by Peter Kerins, OBP, modified by John Robison Hoopes, OBP.


create_table_vessel_manual.txt

  Create a table vessel_manual with attributes.


shipview_snapshot_script.ahk

  A Windows Auto Hotkey script that downloads a snapshot of current AIS pings every 4 hours.
  - Check a few things. Computer on? Windows on? etc.
  - Set timer for the script to run every 14400000 ms (4 hrs).
  - Open Chrome.
  - Open ShipView window.
  - Log in.
  - Download snapshot to Downloads/xxx.csv.
  - Close download bar.
  - Update Tray icon to indicate most recent download time.


sql_backup.txt

  Copies ping_legacy, ping_raw and ping to C:\custom\pg_backup as csv files.



sql_badping_rebuild.txt

  Several scripts from ../database_script_essentials/
  - Create vessel table
  - Create vessel_profile table
  - Create partitions of vessel_profile table A - I, X. -- I have not seen this in action in the 2016 database.
  - Create indexes of vessel_profile_n partitions.
  - Function vessel_profile_insert_trigger() inserts vessel profile values into appropriate partition.
  - Creates trigger that executes vessel_profile_insert_trigger() function on each row.
  - Deletes non-sensical pings.
  - Inserts new data into vessel table, filtering all custom_ids that already exist in table.
  - Inserts data into vessel_profile based on where vessel has been compared to existing High Risk Area, War Risk Area, etc geographies.



sql_create_database_2016.txt

  Creates database structure for 2016 AIS data from exactEarth.
  Hooks in with ahk scripts, etc.

  Includes building partitioned ping tables & indexes by month. -- I have not seen this in action in the 2016 database.

  Defines import_csv() function.



sql_create_database_beta.txt

  Apparently a test doc to create the commands in sql_create_database_2016.txt.



sql_create_database_scratch.txt

  Creates ping_historical_raw table - quite sure this is deprecated.



sql_create_func_latlong.txt

  Defines function calc_decimal_degrees(), which converts Degrees, minutes,
  minutes_dec (?), cardinal formatted coordinate into decimal degrees format.



sql_create_table_incident.txt

  Create incident_raw_main, incident_raw_sop14, incident_raw_sop15 and incident tables.
  (I have not seen this implemented in the 2016 database.)



sql_create_zone.txt

  Creates zone and zone_geog_idx tables. (I have not seen these populated in 2016 database. )




sql_delete_badpings.txt

  Deletes pings with non-sensical or unrealistic data.




sql_delete_duplicates.txt

  Deletes rows in ping by comparing ping with itself (aliased as "pong").
  - Deletes all rows where mmsi, vessel_name AND ts_pos_utc all match except the lowest custom_id..



sql_floating_armories.txt

  Queries the database for known armories.
  Selects data based on name or by including or excluding vessels of known characteristics (vessel_type_code, flag_country attributes).
  Includes command line prompts to export shp files of armories in WA, EA, SEA regions.



sql_func_position.txt

  Defines sql function create_position(). Tests validity of float input values.
  Defines sql function create_position_ts(). Tests validity of float input values and date_time. Sets spatial reference identifier (position_ts) with PostGIS ST_SetSRID() function.




sql_funcs_etc.txt

  calc_speed_optimum()
  - Tests vessel_type_code, length.
  - Returns optimum speed for length based on global snapshot averages.

  calc_speed_buffer()
  - Returns speed buffer based on length.
  (How were speed buffers calculated?? Unclear...)

  calc_speed_threshold()
  - Adds buffer to optimum; returns result as threshold speed value (knots).

  calc_weight()
  - Calculates probable weight based on formula derived from length and vessel_type.

  calc_fuel_usage()
  - Calculates estimated fuel usage with vessel_type, length, speed.
  - Based on equations. (Where did these come from? R?)
  - Two versions of this function...

  calc_group_custom()
  - Returns code (1-6) denoting graduated lengths of different vessel_types.




sql_pgsql_shapefile_exports.txt

  Several command line prompts to create a file (-f) from the data selected by the included SQL query.



sql_populate_incident_*.txt (4 scripts)

  Inserts data into incident tables.
  - Converts data into standardized format (unknown / multiple ship names, activity_type, etc) from incident_raw_main table.



sql_populate_ping_multiple_formats.txt

  Inserts data from ping_raw, ping_legacy into ping table.
  - Clean up variable data (like whitespace at end of vessel_name string, etc.)
  - See sql_populate_ping.txt description.



sql_populate_ping.txt

  Inserts data into ping by attribute from ping_raw.
  - Main transformation is from ping_raw.position (datatype: text) into ping.position (datatype: geography).
  - Builds position_ts data for ping (datatype: geography).
  - Also trims any whitespace from the end of the vessel_name text data. ('\s+$').
  - Sets timestamp data - text in ping_raw - into timestamp datatype in ping.



sql_populate_vessel_profile.txt

  Inserts data into vessel_profile based on PostGIS functions.
  - Checks to see if vessel has entered certain zones (boolean).
  - Unclear on what Left Outer Joins do...




sql_populate_vessel.txt

  Inserts data into vessel table, ensuring that only one copy of the data is entered.



sql_rerouting.txt

  Returns data from vessel_profile_b (?) plus data from relevant zone records
  (left join) where relevant vessel_profile_b agg_geog attribute intersects
  with zone geography (red, goa, eior) and NOT with gnb.



sql_select_agg_filtered_thorough.txt

  - Complex queries that pull out records from ping that have certain characteristics, including
  length, vessel_type, flag, etc.
  - Includes command line prompts to convert the query results into a shapefile.




sql_select_all_full.txt

  Queries database to return ordered ping data, left outer join data from vessel table.



sql_select_fisheries.txt

  Queries database (ping & zone tables) for vessels that entered the Somali EEZ in March.
  Inner joins with pings from March.
  (Unclear...)



sql_select_military_full.txt

  Queries database for information about military vessels, ordered by flag country.



sql_select_zone_*.txt

  Several queries that check the vessel_profile table to see if the vessel has entered zones.
  WHERE clauses filter results by vessel_type_code, length, etc.



sql_speed_calcs.txt

  Queries database for mmsi, vessel_name, etc, plus speed optimum, buffer and threshold.

  Each query filters results based on characteristics (vessel_type_code, length, speed etc.)
  (Several queries, worth a deeper look.)




sql_speed_groups.txt

  Queries database for data including speed by length / vessel type.
  Slices results by 120-199, 200-299, 300+ m.



sql_vessel_profile_alterations.txt

  Alters vessel_profile table to add boolean columns indicating vessel's presence in several zones.
  Updates table by texting if vessel's agg_geog has intersected each zone's geography.



sql_vessel_profile_monthly_with_rerouting.txt

  Creates vessel_profile_monthly table.
  Inserts data into table including mmsi, month, total ping count for that month, etc.
  Several queries including rerouting by geography.
