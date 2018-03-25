class FinancialSummary
  include ActiveModel::Model
  attr_accessor :user_id, :currency, :date_range, :created_at

  def self.one_day(params)
    date_range = (Time.now - 1.day)...Time.now
    self.create_summary(params, date_range)
  end

  def self.seven_days(params)
    date_range = (Time.now - 7.days)...Time.now
    self.create_summary(params, date_range)
  end

  def self.lifetime(params)
    date_range = (Time.now - 100.years)...Time.now
    self.create_summary(params, date_range)
  end

  def self.create_summary(params, date_range)
    begin
      FinancialSummary.new(
        user_id: params[:user][:id],
        currency: params[:currency].to_s.upcase,
        created_at: Time.now,
        date_range: date_range
      )
    rescue
      raise 'Fields must not be blank'
    end
  end

  def count(category)
    Transaction.where(user_id: user_id, category: category, created_at: date_range, amount_currency: currency).count
  end

  def amount(category)
    transactions = Transaction.where(user_id: user_id, category: category, created_at: date_range, amount_currency: currency)
    total = 0
    transactions.each do |t|
      total += t.amount
    end
    total
  end
end
