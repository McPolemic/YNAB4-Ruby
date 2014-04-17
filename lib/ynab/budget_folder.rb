require 'json'
require 'ynab/errors'
require 'pathname'
require 'pry'

module Ynab
  class BudgetFolder
    Metadata = Struct.new( :version, :data_path )
    class Device < Struct.new( :id, :full_id, :full_knowledge, :budget_source , :reader )
      alias :full_knowledge? :full_knowledge

      def budget_data
        reader.call(budget_source)
      end
    end

    def initialize(budget_path, options={})
      @budgetpath = Pathname(budget_path)
      @data_loader = options.fetch(:reader) { method(:load_json_file) }
    end

    def metadata_file
      filepath = @budgetpath.join('Budget.ymeta')
      fail(BudgetFileNotFound, "Metadata File Not Found") unless filepath.file?
      filepath
    end

    def metadata
      jsondata = @data_loader.call metadata_file
      Metadata.new( version = jsondata['formatVersion'],
                    data_path = @budgetpath.join(jsondata['relativeDataFolderName']))
    end

    def device_files
      devicepath = metadata.data_path.join('devices')
      fail(BudgetFileNotFound, "Devices Directory Doesn't Exist") unless devicepath.directory?
      search_path = devicepath.join('*.ydevice')
      Pathname.glob(search_path)
    end

    def devices
      device_files.map do |df|
        jsondata = @data_loader.call df
        Device.new( id = jsondata['shortDeviceId'],
                    full_id = jsondata['deviceGUID'],
                    full_knowledge = jsondata['hasFullKnowledge'],
                    budget_source = metadata.data_path.join(jsondata['deviceGUID'], 'Budget.yfull'),
                    reader = @data_loader )
      end
    end

    def budget_data
      first_full_knowledge_device = devices.find { |d| d.full_knowledge? }
      first_full_knowledge_device.budget_data
    end

    private

    def load_json_file filepath
      JSON.load(File.open(filepath, 'r'))
    end
  end
end
