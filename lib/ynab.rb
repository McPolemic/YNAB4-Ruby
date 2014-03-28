require "ynab/version"

module Ynab
  def self.open file_path
    self::Budget.new file_path
  end

  class Budget
    attr_reader :transactions
    def initialize file_path=nil
      @transactions = []
    end

    def add_transaction t
      @transactions = @transactions + Array(t)
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

  class Account; end
  class Category; end
end
