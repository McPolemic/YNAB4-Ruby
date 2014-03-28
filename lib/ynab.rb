require "ynab/version"

module Ynab
  def self.open file_path
    self::Budget.new file_path
  end

  class Budget
    def initialize file_path
    end

    def transactions
      4.times
    end
  end

  class Transaction
    attr_reader :account,
                :date,
                :payee,
                :category,
                :memo,
                :outflow,
                :inflow

    def initialize account,
                   date,
                   payee,
                   category,
                   memo,
                   outflow,
                   inflow

      @account = account
      @date = date 
      @payee = payee 
      @category = category 
      @memo = memo 
      @outflow = outflow 
      @inflow = inflow
    end
  end

  class Account; end
  class Payee; end
  class Category; end
end
