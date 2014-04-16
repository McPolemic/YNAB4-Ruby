require 'bigdecimal'
require 'ynab'

describe Ynab do
  let(:ynab) { Ynab.open('./spec/fixtures/Test~E8570C74.ynab4') }

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

    it "shows transaction's account"
    it "shows transaction's payee"
    it "shows transaction's category"
  end
end
