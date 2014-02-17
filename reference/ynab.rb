require 'json'

def find_ynab_data_folder
	dropbox_root = File.expand_path('~/Dropbox')
	yroot = JSON.load File.open(File.join(dropbox_root, '.ynabSettings.yroot'))
	base_folder = yroot['relativeKnownBudgets']
	ymeta_path =  File.join(dropbox_root, base_folder, 'Budget.ymeta')
	ymeta = JSON.load File.open(ymeta_path)
	data_folder = ymeta['relativeDataFolderName']
	data_folder_path = File.join(dropbox_root, base_folder, data_folder)
	return data_folder_path
end

def find_complete_budget_path(ynab_data_folder)
	device_folder = File.join(ynab_data_folder, 'devices')
	device_search = File.join(device_folder, '*')
	devices = Dir.glob(device_search)
	device = devices.find do |d|
				device = JSON.load File.open(d)
				device['hasFullKnowledge']
			end
	return File.join(ynab_data_folder, JSON.load(File.open(device))['deviceGUID'], 'Budget.yfull')
end

def parse_ynab_data_file
	data_folder = find_ynab_data_folder
	path = find_complete_budget_path data_folder
	puts path
	budget = JSON.load File.open(path)
	puts budget['masterCategories'].each { |k| k['name']}
end

parse_ynab_data_file