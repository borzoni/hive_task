module Base::InteractorTransaction
  def self.extended(base)
    base.extend ClassMethods
    base.include InstanceMethods
  end

  module ClassMethods
  end

  module InstanceMethods
    def transaction!
      block_result = nil
      ActiveRecord::Base.transaction  do
        begin
          block_result = yield
        rescue RuntimeError, ActiveRecord::RecordInvalid => e
          abort!(e) # signal exception happened
        end

        raise ActiveRecord::Rollback if @exception || block_result.failure? # bubble rollback up if failed
      end

      block_result || Failure(type: :exception, exception: @exception)  # if exception was raised, block result is nil
    end

    private
    def abort!(exception = nil)
      @exception = exception unless exception.nil?
    end
  end
end 
