require 'bigdecimal'
require 'ynab'

describe Ynab do
  let(:ynab) { Ynab.open('./spec/fixtures/Test~E8570C74.ynab4') }

  describe '.payees' do
    let(:payees) { ynab.payees }

    it 'finds payees' do
      expect(payees.count).to eq 5
    end

    it 'names payees' do
      expect(payees[4].name).to eq "Target"
    end

    it 'loads the payee id' do
      expect(payees[4].id).to eq "923CF0E7-F3BF-52C3-2D05-417DDAF133C5"
    end
  end


  describe '.transactions' do
    let(:transactions) { ynab.transactions }
    let(:transaction)  { ynab.transactions.first }

    it 'shows how many total transactions exist for a budget' do
      expect(transactions.count).to eq 4
    end

    it "shows transaction's date" do
      expect(transaction.date).to eq Date.new(2014, 2, 17)
    end

    it "shows transaction's amount" do
      expect(transactions[3].amount).to eq -100.12
    end

    it "shows transaction's memo" do
      expect(transaction.memo).to eq "A sample memo!"
    end

    it "shows transaction's account" do
      expect(transaction.account.name).to eq "Savings"
    end

    it "shows transaction's payee" do
      expect(transaction.payee.name).to eq "Starting Balance"
    end

    it "shows transaction's category" do
      pending "waiting on parsing category objects"
      expect(transaction.category.name).to eq "Income for February"
    end

    it "Shows whether a transaction is cleared" do
      cleared_transaction = transactions.find{|t| t.id == "B850E42E-B8B0-AE20-C396-417D83E94D9C"}
      expect(cleared_transaction.cleared?).to be true
    end
  end

  describe '.accounts' do
    let(:accounts) { ynab.accounts }
    let(:checking) { ynab.accounts.find{|a| a.name == "Checking"} }

    it 'shows how many accounts exist for a budget' do
      expect(accounts.count).to eq 3
    end

    it 'parses the name of an account' do
      expect(accounts.map(&:name).sort).to eq %w{Checking Off-Budget Savings}
    end

    it 'loads all transactions for an account' do
      expect(checking.transactions.count).to eq 2
    end

    # Using floats for money. Do as I say, not as I do.
    # We're read-only, so this is mitigated.
    it 'loads the cleared balance' do
      expect(checking.cleared_balance).to eq 500.00
    end

    it 'loads the working balance' do
      expect(checking.working_balance).to eq 399.88
    end
  end

  describe '.categories' do
    let(:categories) { ynab.categories }
    let(:category) { ynab.categories.find{|a| a.name == "Checking"} }

    it 'shows how many categories exist for a budget' do
      expect(categories.count).to eq 36
    end

    it 'parses the name of an category' do
      expect(categories.first.name).to eq "Hidden Categories"
    end

    it 'parses the name of a subcategory' do
      subcategory = categories.find{|c| c.name == "Charitable"}
      expect(subcategory.name).to eq "Charitable"
    end

    it "parses the name of a subcategory's parent category" do
      subcategory = categories.find{|c| c.name == "Charitable"}
      expect(subcategory.parent.name).to eq "Giving"
    end

    it 'finds a category by ID' do
      spending_money = ynab.find_category_by_id('A18')
      expect(spending_money.name).to eq "Spending Money"
    end

    # There's no real category for "Income for February", but we have
    # to act like there is.
    it 'returns a pseudo-category for IDs that represent income' do
      income_category = ynab.find_category_by_id("Category/__ImmediateIncome__")
      expect(income_category).to be
      expect(income_category.id).to eq "Category/__ImmediateIncome__"
      expect(income_category.name).to eq "Immediate Income"
    end

    it 'returns an income category for income transactions' do
      first_transaction = ynab.transactions.first
      pending "Income category creation"
      expect(first_transaction.category.name).to eq "Income for February"
    end

    it 'loads all transactions for a category' do
      spending_money = categories.find{|c| c.name == "Spending Money"}
      expect(spending_money.transactions.count).to eq 1
    end

  end
end
