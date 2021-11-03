=begin
  Interactors for smart composable services
  
    DI:             dry-intitialier
    Composability:  dry-monads
    Static typing:  dry-schema
    Transactions:   dsl with monadic support and bubbling, nested transactions support included

  Usage:
  
  class NewInteractor

    ## explicit dependencies with types and all the whistles
    option :dependency, default: -> { DependencyClass }
    option :logger, default: -> { Logger.new }  # we may also use types here
    
    ## static typing and validation for inputs
    contract do 
      required(:user).filled(Dry.Types.Instance(User))
      required(:foo).hash do
        optional(:bar).filled(:string)
      end
    end
    
    ## entry_point
    ## `yield` here returns monad for composability 
    ## on Failure shortcircuits and this failure is returned as the result of the whole call
    ## on Success left hand side receives the wrapped value and the computation continues 
    def call!(inputs)
      
      checker = yield service1.call!(user: inputs[:user])
      notifier = yield service2.call!(dep: res)
      event = yield (transaction do
        notifier.notify!
        tag = yield deliver_tag(notifier.stamp)
        ev = Event.new(value: 'notification', time: notifier.time, tag: tag).save!
        Success(ev)
      end)
    end

    def deliver_tag(tag)
      Deliverer.call!(tag)
    end
  end

=end
class Interactor
  extend Base::InteractorValidation
  extend Base::InteractorTransaction

  include Dry::Monads[:result, :do]
  extend Dry::Initializer

  param :args
  attr_reader :inputs

  def self.call!(args={}, &block)
    inst = new(args)
    config = self.dry_initializer.attributes(inst)
    inst.send(:update_dependencies, config)
    inst.send(:_prepare_instance)

    res = inst.instance_variable_get(:@result)
    if !res&.failure?
      res = inst.call!(inst.inputs)  #just for explicitness
    end

    res
  end

  private

  def update_dependencies(config)
    only_args = config[:args]
    config.except(:args).select{ |k, v| only_args.has_key?(k)}.each do |k, v|
      self.instance_variable_set("@#{k}", only_args[k])
    end
  end

  def _prepare_instance
    define_singleton_method(:transaction!) do |&block|
      super(&block)
    end

    validate
  end
end
