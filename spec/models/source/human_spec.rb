require 'spec_helper'

describe Source::Human do

  let(:source_human) { Source::Human.new }

  context 'associations' do

    context 'has_many' do

    end

    context 'belongs_to' do

    end

    context 'has_one' do
      specify 'person' do
        expect(source_human).to respond_to(:people)
      end
      specify 'source_source' do
        expect(source_human).to respond_to(:source_source_roles)
      end
      specify 'role' do
        expect(source_human).to respond_to(:roles)
      end
    end

  end

  context 'validation' do

  end

  specify 'create person with role of human source'

  specify 'a source_human should have a person'
  specify 'a source_source role should have a source'






end
