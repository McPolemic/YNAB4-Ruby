require 'ynab'

describe Ynab do
  let(:ynab) { Ynab.open('./spec/fixtures/Test~E8570C74.ynab4') }

  describe '.transactions' do
    it 'shows how many total transactions exist for a budget' do
      expect(ynab.transactions.count).to eq 4
    end
  end
end
