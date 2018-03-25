require 'rails_helper'

describe FinancialSummary do
  it 'summarizes over one day' do

    user = create(:user)

    Timecop.freeze(Time.now) do
      create(:transaction, user: user, category: :deposit, amount: Money.from_amount(2.12, :usd))
      create(:transaction, user: user, category: :deposit, amount: Money.from_amount(10, :usd))
    end

    Timecop.freeze(2.days.ago) do
      create(:transaction, user: user, category: :deposit)
    end

    subject = FinancialSummary.one_day(user: user, currency: :usd)
    expect(subject.count(:deposit)).to eq(2)
    expect(subject.amount(:deposit)).to eq(Money.from_amount(12.12, :usd))
  end

  it 'only selects transactions from the asked category' do
    user = create(:user)

    Timecop.freeze(Time.now) do
      create(:transaction, user: user, category: :withdraw, amount: Money.from_amount(12.12, :usd))
      create(:transaction, user: user, category: :withdraw, amount: Money.from_amount(10, :usd))
    end

    Timecop.freeze(Time.now) do
      create(:transaction, user: user, category: :refund, amount: Money.from_amount(1.10, :usd))
    end

    subject = FinancialSummary.one_day(user: user, currency: :usd)

    expect(subject.count(:withdraw)).to eq(2)
    expect(subject.amount(:withdraw)).to eq(Money.from_amount(22.12, :usd))

    expect(subject.count(:refund)).to eq(1)
    expect(subject.amount(:refund)).to eq(Money.from_amount(1.10, :usd))

    expect(subject.count(:deposit)).to eq(0)
    expect(subject.amount(:deposit)).to eq(Money.from_amount(0.00, :usd))
  end

  it 'summarizes over seven days' do

    user = create(:user)

    Timecop.freeze(5.days.ago) do
      create(:transaction, user: user, category: :deposit, amount: Money.from_amount(2.12, :usd))
      create(:transaction, user: user, category: :deposit, amount: Money.from_amount(10, :usd))
    end

    Timecop.freeze(8.days.ago) do
      create(:transaction, user: user, category: :deposit)
    end

    subject = FinancialSummary.seven_days(user: user, currency: :usd)
    expect(subject.count(:deposit)).to eq(2)
    expect(subject.amount(:deposit)).to eq(Money.from_amount(12.12, :usd))
  end

  it 'summarizes over lifetime' do

    user = create(:user)

    Timecop.freeze(30.days.ago) do
      create(:transaction, user: user, category: :deposit, amount: Money.from_amount(2.12, :usd))
      create(:transaction, user: user, category: :deposit, amount: Money.from_amount(10, :usd))
    end

    Timecop.freeze(8.days.ago) do
      create(:transaction, user: user, category: :deposit)
    end

    subject = FinancialSummary.lifetime(user: user, currency: :usd)
    expect(subject.count(:deposit)).to eq(3)
    expect(subject.amount(:deposit)).to eq(Money.from_amount(13.12, :usd))
  end

  it 'ensures FinacialSummary has valid fields' do
    user = create(:user)

    Timecop.freeze(Time.now) do
      create(:transaction, user: user, category: :deposit)
    end

    expect{ FinancialSummary.one_day(currency: :usd) }.to raise_error('Fields must not be blank')
    expect { FinancialSummary.one_day(user: user, currency: :usd) }.not_to raise_error
  end
end
