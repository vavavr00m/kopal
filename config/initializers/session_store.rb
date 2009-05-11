# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_t_session',
  :secret      => 'ff8f8fa2b1b21ac4566a174cacd868f3e04be0dec98dd4786e3916dfeeaff5fd1088b40c32062ff0811cbf165861b82247377b90e51c1df5739e51e63eb5527a'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
