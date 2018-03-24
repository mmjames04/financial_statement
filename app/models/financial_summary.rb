class FinancialSummary

  attr_accessor :user, :currency, :created_at

  def self.one_day(params)
    summary = new

    summary.user = params[:user]
    summary.currency = params[:currency].to_s.upcase
    summary.created_at = (Time.now - 1)...Time.now

    summary
  end

  def self.seven_days(params)
    summary = new

    summary.user = params[:user]
    summary.currency = params[:currency].to_s.upcase
    summary.created_at = (Date.today - 7)...Date.today

    summary
  end

  def self.lifetime(params)
    summary = new

    summary.user = params[:user]
    summary.currency = params[:currency].to_s.upcase
    summary.created_at = (Date.today - 100.years)...Date.today

    summary
  end

  def count(category)
    Transaction.where(user: user, category: category, created_at: created_at, amount_currency: currency).count
  end

  def amount(category)
    transactions = Transaction.where(user: user, category: category, created_at: created_at, amount_currency: currency)
    total = 0
    transactions.each do |t|
      total += t.amount
    end
    total
  end
end
