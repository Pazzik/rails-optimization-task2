# frozen_string_literal: true

require_relative 'task-2'
require 'rspec'

RSpec.describe 'Task2' do
  context 'works correctly' do
    let(:expected_result) do
      { 'totalUsers' => 3,
        'uniqueBrowsersCount' => 14,
        'totalSessions' => 15,
        'allBrowsers' =>
        'CHROME 13,CHROME 20,CHROME 35,CHROME 6,FIREFOX 12,FIREFOX 32,FIREFOX 47,INTERNET EXPLORER 10,INTERNET EXPLORER 28,INTERNET EXPLORER 35,SAFARI 17,SAFARI 29,SAFARI 39,SAFARI 49',
        'usersStats' =>
        { 'Leida Cira' =>
          { 'sessionsCount' => 6,
            'totalTime' => '455 min.',
            'longestSession' => '118 min.',
            'browsers' =>
            'FIREFOX 12, INTERNET EXPLORER 28, INTERNET EXPLORER 28, INTERNET EXPLORER 35, SAFARI 29, SAFARI 39',
            'usedIE' => true,
            'alwaysUsedChrome' => false,
            'dates' =>
            %w[2017-09-27
               2017-03-28
               2017-02-27
               2016-10-23
               2016-09-15
               2016-09-01] },
          'Palmer Katrina' =>
          { 'sessionsCount' => 5,
            'totalTime' => '218 min.',
            'longestSession' => '116 min.',
            'browsers' =>
            'CHROME 13, CHROME 6, FIREFOX 32, INTERNET EXPLORER 10, SAFARI 17',
            'usedIE' => true,
            'alwaysUsedChrome' => false,
            'dates' =>
            %w[2017-04-29 2016-12-28 2016-12-20 2016-11-11 2016-10-21] },
          'Gregory Santos' =>
          { 'sessionsCount' => 4,
            'totalTime' => '192 min.',
            'longestSession' => '85 min.',
            'browsers' => 'CHROME 20, CHROME 35, FIREFOX 47, SAFARI 49',
            'usedIE' => false,
            'alwaysUsedChrome' => false,
            'dates' => %w[2018-09-21 2018-02-02 2017-05-22 2016-11-25] } } }
    end
    before { File.write('result.json', '') }

    it 'works correct' do
      work
      actual_result = JSON.parse(File.read('result.json'))
      expect(actual_result).to eq(expected_result)
    end
  end

  context 'works efficiently' do
    let(:size) { 10_000 }
    let(:filename) { "data#{size}.txt" }

    it 'consumes less then 2 mb RAM' do
      memory_before = (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
      work(filename)
      memory_after = (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
      consumed_memory = memory_after - memory_before
      expect(consumed_memory).to be <= 2
    end
  end
end
