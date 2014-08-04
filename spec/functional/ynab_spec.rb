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
      pending "waiting on parsing account objects"
      expect(transaction.account.name).to eq "Savings"
    end

    it "shows transaction's payee" do
      expect(transaction.payee.name).to eq "Starting Balance"
    end

    it "shows transaction's category" do
      pending "waiting on parsing category objects"
    end
  end
end
