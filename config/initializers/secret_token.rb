# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
RemotelyObservedTreatment::Application.config.secret_token = ENV['SECRET_TOKEN'] || '386a7035f2ecb17a72b3ac14489aeec9f3f1ab49d3a1760d0b07e503363fa514e28bd7eb0682140d334bb3fa5bece97970967212eba0dfcee9c036e68f78b734'
