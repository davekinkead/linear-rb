require 'spec_helper'

RSpec.describe Linear::Formatters do
  describe '.priority_label' do
    it 'returns correct label for valid priority' do
      expect(described_class.priority_label(2)).to eq('High')
    end

    it 'returns Unknown for invalid priority' do
      expect(described_class.priority_label(99)).to eq('Unknown')
    end
  end
end
