# frozen_string_literal: true

require 'semgrep/changes/checker'
require 'semgrep/changes/shell'

RSpec.describe Semgrep::Changes::Checker do
  let(:commit) { nil }
  let(:auto_correct) { false }

  subject do
    described_class.new(
      report: 'spec/semgrep/changes/semgrep.json',
      quiet: false,
      commit: commit,
      base_branch: 'master'
    ).run
  end

  context 'when the fork point is not known' do
    it 'raises an exception' do
      expect(Semgrep::Changes::Shell).to receive(:run).with(
        'git merge-base HEAD origin/master'
      ).and_return('')

      expect do
        subject
      end.to raise_error(Semgrep::Changes::UnknownForkPointError)
    end

    context 'by given commit id' do
      let(:commit) { 'deadbeef' }

      it 'raises an exception' do
        expect(Semgrep::Changes::Shell).to receive(:run).with(
          'git log -n 1 --pretty=format:"%h" deadbeef'
        ).and_return('')

        expect do
          subject
        end.to raise_error(Semgrep::Changes::UnknownForkPointError)
      end
    end
  end

  context 'when the fork point is known' do
    let(:diff_files) do
      %w[lib/semgrep/changes/check.rb]
    end

    let(:git_diff) { File.read('spec/semgrep/changes/sample.diff') }
    let(:offenses) { File.read('spec/semgrep/changes/semgrep.json') }

    let(:total_offenses) do
      JSON.parse(offenses)['results'].count
    end

    it 'runs a git diff' do
      expect(Semgrep::Changes::Shell).to receive(:run).with(
        'git merge-base HEAD origin/master'
      ).and_return('deadbeef')

      expect(Semgrep::Changes::Shell).to receive(:run).with(
        'git diff deadbeef'
      ).and_return(git_diff)

      expect(total_offenses).to be(1)
      expect(subject).to be(0)
    end

    context 'by given commit id' do
      let(:commit) { 'deadbeef' }

      it 'runs a git diff' do
        expect(Semgrep::Changes::Shell).to receive(:run).with(
          'git log -n 1 --pretty=format:"%h" deadbeef'
        ).and_return('deadbeef')

        expect(Semgrep::Changes::Shell).to receive(:run).with(
          'git diff deadbeef'
        ).and_return(git_diff)

        expect(total_offenses).to be(1)
        expect(subject).to be(0)
      end
    end

    context 'when FIXME flag is not present' do
      it do
        expect(Semgrep::Changes::Shell).to receive(:run).with(
          'git merge-base HEAD origin/master'
        ).and_return('deadbeef')

        expect(Semgrep::Changes::Shell).to receive(:run).with(
          'git diff deadbeef'
        ).and_return(git_diff)

        expect(subject).to be(0)
      end
    end
  end
end
