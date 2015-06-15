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
end
