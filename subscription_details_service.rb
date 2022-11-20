# frozen_string_literal: true

require 'date'
require 'time' # ~> For Integer.month computation
# Subscription Details is a service cthat lass initializes the start date of subscription and contains all the
# functionalities to compute the final result
class SubscriptionDetailsService
  def initialize(start_date: nil)
    @date = start_date
    @start_date = valid_date?(start_date)
    puts 'INVALID_DATE' if valid_date?(@date) == 'invalid date'
    @renewal_details = {}
    @top_up_count = 0
    @total = 0
  end

  # All Do Re Mi subscription plans are saved as an YAML to preserve space and easy modification when new plans are
  # added.
  def plan_details(category:, plan:)
    YAML.load_file('./do_re_mi_plans.yml')[category.downcase][plan.downcase]
  end

  # Validates the date in DD-MM-YYYY format
  def valid_date?(start_date)
    DateTime.strptime(start_date, '%d-%m-%Y')
  rescue Date::Error => e
    e.message
  end

  # Adds Subscription details to instance variables
  def add_subscription_details(category:, plan:)
    if valid_date?(@date) == 'invalid date'
      puts 'ADD_SUBSCRIPTION_FAILED INVALID_DATE'
      return
    end
    add_category_details(category: category, plan: plan)
  end

  # Adds category details and computes the renewal date by adding a month and subtracting 10 days. Could have used 21
  # days (31-10 days) but sticked with ruby month functionality.
  def add_category_details(category:, plan:)
    plan_detail = plan_details(category: category, plan: plan)
    if @renewal_details[category].nil?
      @renewal_details[category] = { 'date' => (@start_date.next_month(plan_detail['duration']) - 10).strftime('%d-%m-%Y') }
      @total += plan_detail['price']
    else
      puts 'ADD_SUBSCRIPTION_FAILED DUPLICATE_CATEGORY'
    end
  end

  # Adds top up details and increments the @total instance variable to have the final price. Count incremented first
  # rather than adding at the bottom and putting a check at top to work for more efficiently when it's put up with a db
  # and the process will be asynchronous.
  def add_top_up_details(category:, plan:, duration:)
    @top_up_count += 1

    if valid_date?(@date) == 'invalid date'
      puts 'ADD_TOPUP_FAILED INVALID_DATE'
    elsif  @renewal_details == {}
      puts 'ADD_TOPUP_FAILED SUBSCRIPTIONS_NOT_FOUND'
    elsif @top_up_count > 1
      puts 'ADD_TOPUP_FAILED DUPLICATE_TOPUP'
    else
      plan_detail = plan_details(category: category, plan: plan)
      @total += (duration.to_i * plan_detail['price'])
    end
  end

  # Prints the final subscription details
  def print_subscription_details
    if @renewal_details == {}
      puts 'SUBSCRIPTIONS_NOT_FOUND'
    else
      @renewal_details.each do |key, value|
        puts "RENEWAL_REMINDER #{key} #{value['date']}"
      end
      puts "RENEWAL_AMOUNT #{@total}"
    end
  end
end
