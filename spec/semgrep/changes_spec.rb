# frozen_string_literal: true

RSpec.describe Semgrep::Changes do
  it 'has a version number' do
    expect(Semgrep::Changes::VERSION).not_to be nil
  end
end
