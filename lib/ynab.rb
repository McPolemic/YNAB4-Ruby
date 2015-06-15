require "date"

require "ynab/version"
require 'ynab/budget_folder'
require 'ynab/errors'

module Ynab
  def self.open file_path
    self::Budget.open file_path
  end

  class Budget
    attr_reader :transactions,
                :payees,
                :categories,
                :accounts
    def initialize
      @transactions = []
      @payees = []
      @categories = []
      @accounts = []
    end

    def add_transaction transaction
      @transactions = @transactions + Array(transaction)
    end

    def add_payee payee
      @payees = @payees + Array(payee)
    end

    def add_category category
      @categories = @categories + Array(category)
    end

    def add_account account
      @accounts = @accounts + Array(account)
    end

    def self.open file_path
      data = BudgetFolder.new(file_path).budget_data
      budget = self.new
      budget.populate_payees data
      budget.populate_accounts data
      budget.populate_transactions data

      budget
    end

    def populate_payees budget_data
      budget_data['payees'].each do |p|
        payee = Payee.new(id = p['entityId'],
                          name = p['name'])
        add_payee(payee)
      end
    end

    def find_payee_by_id id
      @payees.find_all{|p| p.id == id}.first
    end

    def populate_accounts budget_data
      budget_data['accounts'].each do |p|
        account = Account.new(id = p['entityId'],
                              name = p['accountName'],
                              hidden = p['hidden'],
                              last_reconciled_date = p['lastReconciledDate'],
                              last_reconciled_balance = p['lastReconciledBalance'])
        add_account(account)
      end
    end

    def find_account_by_id id
      @accounts.find_all{|p| p.id == id}.first
    end

    def populate_transactions budget_data
      budget_data["transactions"].each do |t|
        payee = find_payee_by_id t['payeeId']
        account = find_account_by_id t['accountId']

        transaction = Transaction.new(account = account,
                                      date = Date.parse(t["date"]),
                                      payee = payee,
                                      category = t["categoryId"],
                                      memo = t["memo"],
                                      amount = t["amount"])
        add_transaction(transaction)
        account.add_transaction(transaction)
      end
    end
  end

  class Payee
    attr_reader :id, :name

    def initialize id, name
      @id = id
      @name = name
    end

    def to_s
      "#<Payee: #{@name}>"
    end
  end

  class Account
    attr_reader :id,
                :name,
                :hidden,
                :last_reconciled_date,
                :last_reconciled_balance,
                :transactions

    def initialize id, name, hidden, last_reconciled_date, last_reconciled_balance
      @id = id
      @name = name
      @hidden= hidden
      @last_reconciled_date = last_reconciled_date
      @last_reconciled_balance = last_reconciled_balance
      @transactions = []
    end

    def to_s
      "#<Account: #{@name}>"
    end

    def add_transaction t
      @transactions << t
    end
  end

  class Transaction
    attr_reader :account,
                :date,
                :payee,
                :category,
                :memo,
                :amount

    def initialize account,
                   date,
                   payee,
                   category,
                   memo,
                   amount

      @account = account
      @date = date
      @payee = payee
      @category = category
      @memo = memo
      @amount = amount
    end

    def inflow
      @amount if @amount > 0
    end

    def outflow
      @amount if @amount < 0
    end
  end

  class Category
    attr_reader :id, :name, :parent

    def initialize id, name, parent = nil
      @id = id
      @name = name
      @parent = parent
    end

    def full_name
      if parent
        "#{parent.full_name}/#{name}"
      else
        name
      end
    end

    def to_s
      "#<Category: #{full_name}>"
    end
  end
end
