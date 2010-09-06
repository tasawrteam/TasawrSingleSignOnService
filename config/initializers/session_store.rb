# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_tasawr_sso_session',
  :secret      => '4e061edf7d0a43a67025b70d4da7e3b165e1df09d12ddde372d91d5d27f730399e150d93e1de3ef9a2fc7e7332a2e6cb127dfc434dde6c279a0be64d20fc787c'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
ActionController::Base.session_store = :active_record_store
