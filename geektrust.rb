# frozen_string_literal: true

# Created by: Alan Easow
# Date : Nov 20 2022
# Contact Info: +91-8921498582
# E-mail : alaneasow@gmail.com

# Requiring Streaming app service which handles all the processing of data
require './streaming_app'

def main
  input_file = ARGV[0]
  # Generate Subscription detail is a function in streaming_app_service.rb which handles all the logic and computation
  # and prints the result.
  ::StreamingApp.new(input_file).generate_subscription_renewal_detals
end

main
