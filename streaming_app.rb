require 'yaml'
require './subscription_details_service'

# The main class where the file is processed and data is passed on to correspondind services to
# compute the output.
class StreamingApp
  def initialize(input_file)
    # Wrapped in rescue to handle cases where the path is invalid or nil
    @_input_file = File.read(input_file)
    @data = @_input_file.split("\n")
  rescue TypeError, Errno::ENOENT => e
    puts 'Error!! Kindly specify a valid input path. Thankyou.'
    puts "Error Message: #{e.message}"
    exit!
  end

  # Main function where the data is processed and passed on for computation. 
  def generate_subscription_renewal_detals
    @subscription_details = nil
    @data.each do |input|
      details = input.split
      subscription_result(details)
    end
  end

  # Categorises data from input and passes down to corresponding functions.
  def subscription_result(details)
    case details[0]
    when 'START_SUBSCRIPTION'
      @subscription_details = upsert_start_subscription_details(start_date: details[1])
    when 'ADD_SUBSCRIPTION'
      upsert_add_subscription_details(object: @subscription_details, category: details[1], plan: details[2])
    when 'ADD_TOPUP'
      upsert_add_top_up_details(object: @subscription_details, plan: details[1], duration: details[2])
    when 'PRINT_RENEWAL_DETAILS'
      print_result(object: @subscription_details)
    else
      'Wrong Command Entered!'
    end
  end

  # Initial setting up of the object also takes place with this function. As we are not using any db for
  # this task we'll setting up an object and reusing the same oject in memory. The function returns subscripton
  # details which is set up as instance variable from where the function is called.
  def upsert_start_subscription_details(start_date:)
    subscription_detail = SubscriptionDetailsService.new(start_date: start_date)
    subscription_detail.valid_date?(start_date)
    subscription_detail
  end

  # Adds the subscription details by calling the function in subscription details service.
  # Also puts a check to return bad input if a wrong category is entered in input.
  def upsert_add_subscription_details(object:, category:, plan:)
    unless %w[MUSIC VIDEO PODCAST].include? category
      pp 'Invalid Category. Bad Input'
      exit!
    end
    object.add_subscription_details(category: category, plan: plan)
  end

  # Function adds the top up details. Since there were no different topup categories explicitly passing category.
  def upsert_add_top_up_details(object:, plan:, duration:)
    object.add_top_up_details(category: 'topup', plan: plan, duration: duration)
  end

  # Prints the final result in terminal/console. Happy coding :)
  def print_result(object: subscription_details)
    object.print_subscription_details
  end
end
