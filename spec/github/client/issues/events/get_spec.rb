# encoding: utf-8

require 'spec_helper'

describe Github::Client::Issues::Events, '#list' do
  let(:user) { 'peter-murach' }
  let(:repo) { 'github' }
  let(:event_id) { 1 }
  let(:request_path) { "/repos/#{user}/#{repo}/issues/events/#{event_id}" }

  before {
    stub_get(request_path).to_return(:body => body, :status => status,
      :headers => {:content_type => "application/json; charset=utf-8"})
  }

  after { reset_authentication_for(subject) }

  context "resource found" do
    let(:body) { fixture('issues/event.json') }
    let(:status) { 200 }

    it { is_expected.to respond_to :find }

    it { expect { subject.get }.to raise_error(ArgumentError) }

    it "should fail to get resource without event id" do
      expect { subject.get user, repo }.to raise_error(ArgumentError)
    end

    it "should get the resource" do
      subject.get user, repo, event_id
      expect(a_get(request_path)).to have_been_made
    end

    it "should get event information" do
      event = subject.get user, repo, event_id
      expect(event.actor.id).to eq event_id
      expect(event.actor.login).to eq 'octocat'
    end

    it "should return mash" do
      event = subject.get user, repo, event_id
      expect(event).to be_a Github::ResponseWrapper
    end
  end

  it_should_behave_like 'request failure' do
    let(:requestable) { subject.get user, repo, event_id }
  end
end # get
