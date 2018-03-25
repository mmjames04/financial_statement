class FinancialSummary
  attr_accessor :user_id, :currency, :date_range, :created_at

  def self.one_day(params)
    summary = new
    summary.summary_builder(summary, params)
    summary.date_range = (Time.now - 1)...Time.now
    summary if summary.valid_fields?(summary)
  end

  def self.seven_days(params)
    summary = new
    summary.summary_builder(summary, params)
    summary.date_range = (Time.now - 7.days)...Time.now
    summary if summary.valid_fields?(summary)
  end

  def self.lifetime(params)
    summary = new
    summary.summary_builder(summary, params)
    summary.date_range = (Time.now - 100.years)...Time.now
    summary if summary.valid_fields?(summary)
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

  def summary_builder(summary, params)
    summary.user_id = params[:user].id if params[:user]
    summary.currency = params[:currency].to_s.upcase if params[:currency]
    summary.created_at = Time.now
  end

  def valid_fields?(summary)
    summary.user_id && summary.currency && summary.date_range && summary.created_at
  end
end
