require 'securerandom'
require_relative '../../lib/budget_parser.rb'

describe Ynab::BudgetParser do
  let(:bp) { Ynab::BudgetParser.new('./test') }

  describe '#open' do
    it 'loads and parses the main budget file' do
      data_file = './test/data123456/Budget.yfull'
      bp.should_receive(:main_data_file).and_return(data_file)
      File.should_receive(:open).with(data_file, "r")

      expect(bp.open).to eq nil
    end
  end

  describe '#index_file' do
    it 'determines the index file' do
      File.should_receive(:exists?).and_return(true)
      expect(bp.index_file).to eq './test/Budget.ymeta'
    end

    it 'raises an error if the index file does not exist' do
      File.should_receive(:exists?).and_return(false)
      expect{bp.index_file}.to raise_error Ynab::BudgetFileNotFound
    end
  end

  describe '#data_folder' do
    let(:fake_data_file) {StringIO.new <<EOF
{
  "relativeDataFolderName": "data123456",
  "formatVersion": "2"
}
EOF
    }

    it 'parses the meta file and finds the data directory' do
      File.should_receive(:exists?).twice.and_return(true)
      File.should_receive(:open).and_return(fake_data_file)
      expect(bp.data_folder).to eq './test/data123456'
    end

    it 'raises an exception if the data directory does not exist' do
      File.should_receive(:exists?).with('./test/Budget.ymeta').and_return(true)
      File.should_receive(:exists?).with('./test/data123456').and_return(false)
      File.should_receive(:open).and_return(fake_data_file)
      expect{bp.data_folder}.to raise_error Ynab::BudgetFileNotFound
    end
  end

  describe '#main_device' do
    it 'returns the path for the main (A) device' do
      bp.should_receive(:data_folder).and_return('./test/data123456')
      File.should_receive(:exists?).and_return(true)
      expect(bp.main_device).to eq './test/data123456/devices/A.ydevice'
    end

    it 'raises an error if it cannot find the main device' do
      bp.should_receive(:data_folder).and_return('./test/data123456')

      expect{bp.main_device}.to raise_error Ynab::BudgetFileNotFound
    end
  end

  describe '#scan_for_main_device' do
    it 'returns the path with the full budget knowledge'
    it 'raises an error if no device currently has full knowledge'
  end

  describe '#main_data_file' do
    let(:guid) { SecureRandom.uuid }
    let(:fake_device_path) { './test/devices/A.ydevice' }
    let(:fake_device_file) { StringIO.new <<EOF
{
	"hasFullKnowledge": true,
	"deviceGUID": "#{guid}"
}
EOF
    }
    it 'returns the path for the data file to read' do
      bp.should_receive(:main_device).and_return(fake_device_path)
      bp.should_receive(:data_folder).and_return('./test/data123456')
      File.should_receive(:exists?).and_return(true)
      File.should_receive(:open).with(fake_device_path, "r").and_return(fake_device_file)
      expect(bp.main_data_file).to eq "./test/data123456/#{guid}/Budget.yfull"
    end

    it 'raises an error if it cannot find the main data file' do
      bp.should_receive(:main_device).and_return(fake_device_path)
      bp.should_receive(:data_folder).and_return('./test/data123456')
      File.should_receive(:exists?).and_return(false)
      File.should_receive(:open).with(fake_device_path, "r").and_return(fake_device_file)
      expect{bp.main_data_file}.to raise_error Ynab::BudgetFileNotFound
    end
  end
end
