require 'spec_helper'
require 'securerandom'
require 'ynab/budget_folder'
require 'fileutils'
require 'tempfile'
require 'json'

describe Ynab::BudgetFolder do
  describe '#metadata_file', fakefs: true do
    let(:budget_dir) { Pathname('/testdir') }
    let(:bf) { Ynab::BudgetFolder.new(budget_dir) }

    before { FileUtils.mkdir_p budget_dir }

    it 'identifies the file' do
      FileUtils.touch budget_dir.join('Budget.ymeta')
      expect(bf.metadata_file).to eq budget_dir.join('Budget.ymeta')
    end

    it 'raises an exception if the file is missing' do
      expect { bf.metadata_file }.to raise_error Ynab::BudgetFileNotFound, 'Metadata File Not Found'
    end
  end

  describe '#metadata' do
    it 'reads json data into Metadata' do
      testfile = Tempfile.open('Budget.ymeta')
      jsontext = {
        "relativeDataFolderName" => "data123456",
        "formatVersion" => 3
      }.to_json
      testfile.puts jsontext
      testfile.close
      testfile_dir = File.dirname testfile

      bf = Ynab::BudgetFolder.new(testfile_dir)
      allow(bf).to receive(:metadata_file).and_return(testfile.path)
      md = bf.metadata
      expect(md).to eq Ynab::BudgetFolder::Metadata.new(3, Pathname(File.join(testfile_dir, 'data123456')))
    end
  end

  describe '#device_files', fakefs: true do
    let(:budget_dir) { Pathname('/testdir') }
    let(:devices_dir) { budget_dir.join('data123456', 'devices') }
    let(:bf) { Ynab::BudgetFolder.new(budget_dir) }
    let(:md) { Ynab::BudgetFolder::Metadata.new(2, budget_dir.join('data123456')) }

    before do
      allow(bf).to receive(:metadata).and_return md
    end

    it 'identifies the file' do
      FileUtils.mkdir_p devices_dir
      FileUtils.touch devices_dir.join('A.ydevice')
      FileUtils.touch devices_dir.join('C.ydevice')
      expect(bf.device_files).to include devices_dir.join('A.ydevice')
      expect(bf.device_files).to include devices_dir.join('C.ydevice')
    end

    it 'raises an exception if the directory is missing' do
      expect { bf.device_files }.to raise_error Ynab::BudgetFileNotFound, "Devices Directory Doesn't Exist"
    end
  end

  describe '#devices' do
    let(:budget_dir) { Pathname('/testdir') }
    let(:data_dir) { budget_dir.join('data123456') }
    let(:dh1) { dev_hash(1, true) }
    let(:dh2) { dev_hash(2, false) }

    def loader data_file
      return dh1 if data_file == 1
      return dh2 if data_file == 2
    end

    def dev_hash(id, fk)
      { 'shortDeviceId' => id.to_s,
        'deviceGUID' => id.to_s,
        'hasFullKnowledge' => fk }
    end

    def new_device(dev_hash)
      Ynab::BudgetFolder::Device.new(dev_hash['shortDeviceId'],
                                     dev_hash['deviceGUID'],
                                     dev_hash['hasFullKnowledge'],
                                     data_dir.join(dev_hash['deviceGUID'], 'Budget.yfull'),
                                     method(:loader))
    end

    it 'provides devices for each device fie' do
      bf = Ynab::BudgetFolder.new(budget_dir, reader: method(:loader))
      allow(bf).to receive(:device_files).and_return [1, 2]
      allow(bf).to receive(:metadata).and_return Ynab::BudgetFolder::Metadata.new(2, data_dir)

      dv1 = new_device(dh1)
      dv2 = new_device(dh2)

      expect( bf.devices ).to eq [ dv1, dv2 ]
    end
  end

  describe '#budget_data' do
    it 'gets the budget data from the device' do
      FakeDev = Struct.new(:full_knowledge?, :budget_data)
      bf = Ynab::BudgetFolder.new('/nodir')
      allow(bf).to receive(:devices).and_return [FakeDev.new(true, "BUDGET DATA")]
      expect(bf.budget_data).to eq "BUDGET DATA"
    end
  end
end

describe Ynab::BudgetFolder::Device do
  describe '#budget_data' do
    it 'can load budget data from source' do
      device = Ynab::BudgetFolder::Device.new('1', 'GUID1', true, 'BUDGET DATA', ->(source) { source })
      expect(device.budget_data).to eq "BUDGET DATA"
    end
  end
end
