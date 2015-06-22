require 'crawlerb/scheduler'

RSpec.describe Crawlerb::Scheduler do
  let(:redis_mock) do
    redis_mock = double('redis client')
    allow(redis_mock).to receive(:multi) { |&block| block.call }
    redis_mock
  end

  describe '#push' do
    context "push new valid url" do
      it "push url to redis" do
        allow(redis_mock).to receive(:sismember).and_return(false)

        expect(redis_mock).to receive(:sadd).exactly(2).times

        scheduler = Crawlerb::Scheduler.instance
        allow(scheduler).to receive(:redis).and_return(redis_mock)
        expect(scheduler.push("http://abc.com")).to eq true
      end
    end

    context "push old valid url" do
      it "don't push url to redis" do
        allow(redis_mock).to receive(:sismember).and_return(true)

        scheduler = Crawlerb::Scheduler.instance
        allow(scheduler).to receive(:redis).and_return(redis_mock)
        expect(scheduler.push("http://abc.com")).to eq false
      end
    end

    context "push invalid url" do
      it "don't push invalid url to redis" do
        allow(redis_mock).to receive(:sismember).and_return(false)

        scheduler = Crawlerb::Scheduler.instance
        allow(scheduler).to receive(:redis).and_return(redis_mock)
        expect(scheduler.push("abc.com")).to eq false
      end
    end
  end

  describe '#pop' do
    it "return a new url" do
      allow(redis_mock).to receive(:spop)
    end
  end
end
