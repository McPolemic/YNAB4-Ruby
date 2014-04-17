require 'ynab'

describe Ynab do
  describe Ynab::Budget do
    let(:budget) { Ynab::Budget.new }

    describe '#add_account' do
      it 'adds and stores accounts' do
        account = 'Savings'
        budget.add_account account
        expect(budget.accounts.count).to eq 1
      end
    end

    describe '#add_category' do
      it 'adds and stores categories' do
        category = 'Spending Money'
        budget.add_category category
        expect(budget.categories.count).to eq 1
      end
    end

    describe '#add_payee' do
      it 'adds and stores payees' do
        payee = 'Target'
        budget.add_payee(payee)
        expect(budget.payees.count).to eq 1
      end
    end

    describe '#add_transaction' do
      it 'adds and stores transactions' do
        t = Ynab::Transaction.new('Savings',
                                  Date.new(2014, 3, 26), 
                                  'Target',
                                  'Spending Money',
                                  "This is a memo",
                                  -100.00)
        budget.add_transaction(t)
        expect(budget.transactions.count).to eq 1
      end
    end

    describe '.open' do
      it 'raises an error if the file does not exist' do
        invalid_path = '/invalid'
        expect{Ynab::Budget.open(invalid_path)}.to raise_error Ynab::BudgetFileNotFound, "Metadata File Not Found"
      end
    end
  end

  describe Ynab::Transaction do
    describe '#new' do
      let(:account)  { 'Savings' }
      let(:category) { 'Spending Money' }
      let(:payee)    { 'Target' }

      it 'stores values for a debit transaction' do
        t = Ynab::Transaction.new(account,
                                  Date.new(2014, 3, 26), 
                                  payee,
                                  category,
                                  "This is a memo",
                                  -100.00)

        expect(t.date).to eq Date.new(2014, 3, 26)
        expect(t.payee).to eq 'Target'
        expect(t.outflow).to eq -100.00
        expect(t.inflow).to eq nil
      end

      it 'stores values for a credit transaction' do
        t = Ynab::Transaction.new(account,
                                  Date.new(2014, 2, 28),
                                  payee,
                                  category,
                                  "Another memo",
                                  200.00)
        expect(t.date).to eq Date.new(2014, 2, 28)
        expect(t.payee).to eq 'Target'
        expect(t.inflow).to eq 200.00
        expect(t.outflow).to eq nil
      end
    end
  end
end
