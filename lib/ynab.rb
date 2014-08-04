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
      budget.populate_transactions data

      budget
    end

    def populate_transactions budget_data
      budget_data["transactions"].each do |t|
        transaction = Transaction.new(account = t["accountId"],
                                      date = Date.parse(t["date"]),
                                      payee = t["payeeId"],
                                      category = t["categoryId"],
                                      memo = t["memo"],
                                      amount = t["amount"])
        add_transaction(transaction)
      end
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
end
