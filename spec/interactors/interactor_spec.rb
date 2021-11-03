# frozen_string_literal: true

require 'dry/monads/result'
require 'rails_helper'

RSpec.describe Interactor do
  let(:args) do
    {
      foo: 'foo',
      bar: 1
    }
  end

  let(:klass) do
    Class.new(described_class) do
      option :dependency, default: -> { 'dep' }

      contract do
        params do
          required(:foo).filled(:str?)
          optional(:bar).filled(:int?)
        end
      end

      def call!(inputs)
        Success(self)
      end
    end
  end

  subject { klass.call!(args) }

  describe '#initialize' do
    it 'validates given args using defined schema without errors' do
      expect(subject.value!.inputs).to be_present
      expect(subject.value!.inputs).to have_key(:foo)
    end

    context 'default dependency' do
      it 'sets default dependency' do
        expect(subject.value!.dependency).to be_present
      end

      context 'passed dependency' do
        let(:new_val) { 'new_val' }
        let(:args) do
          {
            foo: 'foo',
            bar: 1,
            dependency: new_val
          }
        end

        it 'sets dependency by call' do
          expect(subject.value!.dependency).to eq(new_val)
        end
      end
    end

    it 'allows to successfully execute without any problems' do
      expect(subject.success?).to be true
    end

    context 'when args are invalid' do
      let(:args) do
        {
          foo: nil
        }
      end

      it 'mark execution as failed before call!' do
        expect(subject.failure?).to be true
      end

      it 'validates a field' do
        expect(subject.failure[:errors]).to have_key(:foo)
      end
    end

    context 'when optional arg is missing' do
      let(:args) do
        {
          foo: 'foo'
        }
      end

      it 'marks execution as successful' do
        expect(subject.success?).to be true
      end

      it 'validates a field' do
        expect(subject.value!.inputs[:bar]).to be nil 
      end
    end

    context 'when contract is missing' do
      let(:args) do
        {
          foo: 'foo',
          bar: 'bar'
        }
      end

      let(:klass) do
        Class.new(described_class) do
          def call!(inputs)
            Success(self)
          end
        end
      end

      it 'marks execution as successful' do
        expect(subject.success?).to be true
      end

      it 'validates a field' do
        expect(subject.value!.inputs.keys.size) == 2 
      end
    end
  end

  describe '#transaction' do
    let(:db_call_outer) do
      ->(this) {
        this.instance_exec do
          r = User.create(email: 'test@mail.com', password: '123456')
          Success(r)
        end
      }
    end
    let(:db_call_inner) do 
      ->(this) {
        this.instance_exec do
          r = User.create(email: 'test2@mail.com', password: '123456')
          Success(r)
        end
      }
    end
    let(:block) do
      ->(this) {
        this.instance_exec(db_call_outer, db_call_inner) do |outer, inner|
          transaction! do 
            outer.call(this).bind do |rec1|  # no monadic yield available
              transaction! do 
                rec2 = inner.call(this)

              end
            end
          end
        end
      }     
    end

    let(:klass) do
      instance_exec(block) do |block|
        Class.new(described_class) do
          option :dependency, default: -> { 'dep' }

          contract do
            params do
              required(:foo).filled(:str?)
              optional(:bar).filled(:int?)
            end
          end
          define_method :call! do |inputs|
            block.call(self)
          end
        end
      end
    end

    context 'when calls successful' do
      it 'marks executes transaction and marks success' do
        expect { subject }.to change(User, :count).by(2)
        expect(subject.success?).to be true
      end
    end

    context 'when inner fails' do
      let(:test_label) { 'test_inner' }

      let(:db_call_inner) do 
        ->(this) {
          this.instance_exec(test_label) do |label|
            Failure(label)
          end
        }
      end
      it 'executes transaction and marks failure with inner res' do
        expect { subject }.not_to change(User, :count)
        expect(subject.failure?).to be true
        expect(subject.failure).to be == test_label
      end
    end

    context 'when outer fails' do
      let(:test_label) { 'test_outer' }
      let(:db_call_outer) do 
        ->(this) {
          this.instance_exec(test_label) do |label|
            Failure(label)
          end
        }
      end
      it 'executes transaction and marks failure with outer res' do
        expect { subject }.not_to change(User, :count)
        expect(subject.failure?).to be true
        expect(subject.failure).to be == test_label
      end
    end

    context 'when inner raises exception' do
      let(:test_label) { 'test_inner' }
      let(:db_call_inner) do 
        ->(this) {
          this.instance_exec(test_label) do |label|
            raise ActiveRecord::RecordInvalid
          end
        }
      end
      it 'executes transaction and rollbacks on exception' do
        expect { subject }.not_to change(User, :count)
        expect(subject.failure?).to be true
        expect(subject.failure[:exception]).to be_present
      end
    end

    context 'when outer raises exception' do
      let(:test_label) { 'test_outer' }
      let(:db_call_outer) do 
        ->(this) {
          this.instance_exec(test_label) do |label|
            raise ActiveRecord::RecordInvalid
          end
        }
      end
      it 'executes transaction and rollbacks on exception' do
        expect { subject }.not_to change(User, :count)
        expect(subject.failure?).to be true
        expect(subject.failure[:exception]).to be_present
      end
    end
  end
end
