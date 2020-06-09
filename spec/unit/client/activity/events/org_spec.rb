# encoding: utf-8

require 'spec_helper'

describe Github::Client::Activity::Events, '#organization' do
  let(:org) { 'github' }
  let(:request_path) { "/orgs/#{org}/events" }
  let(:body) { fixture('events/events.json') }
  let(:status) { 200 }

  before {
    stub_get(request_path).to_return(:body => body, :status => status,
      :headers => {:content_type => "application/json; charset=utf-8"})
  }

  after { reset_authentication_for subject }

  context "resource found" do
    it { is_expected.to respond_to :organization }

    it "should fail to get resource without orgname" do
      expect { subject.organization }.to raise_error(ArgumentError)
    end

    it "should get the resources" do
      subject.organization org
      expect(a_get(request_path)).to have_been_made
    end

    it_should_behave_like 'an array of resources' do
      let(:requestable) { subject.org org }
    end

    it "should get event information" do
      events = subject.organization org
      expect(events.first.type).to eq('Event')
    end

    it "should yield to a block" do
      yielded = []
      result = subject.organization(org) { |obj| yielded << obj }
      expect(yielded).to eq(result)
    end
  end

  it_should_behave_like 'request failure' do
    let(:requestable) { subject.organization org }
  end

end # org
