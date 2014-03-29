require 'json'
require 'ynab/errors'

module Ynab
  class BudgetParser
    def initialize file_path
      @path = file_path
    end

    def open
      JSON.load(File.open(main_data_file, 'r'))
    end

    def index_file
      index = File.join(@path, 'Budget.ymeta')
      raise Ynab::BudgetFileNotFound unless File.exists? index
      index
    end

    def data_folder
      index = JSON.load(File.open(index_file, 'r'))
      folder = File.join(@path, index['relativeDataFolderName'])
      raise Ynab::BudgetFileNotFound unless File.exists? folder
      folder
    end

    def main_device
      main = File.join(data_folder, 'devices', 'A.ydevice')
      raise Ynab::BudgetFileNotFound unless File.exists? main
      main
    end

    def main_data_file
      main_device_guid = JSON.load(File.open(main_device, 'r'))['deviceGUID']
      data_file = File.join(data_folder, main_device_guid, 'Budget.yfull')
      raise Ynab::BudgetFileNotFound unless File.exists? data_file
      data_file
    end
  end
end
