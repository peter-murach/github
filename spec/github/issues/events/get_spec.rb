# encoding: utf-8

require 'spec_helper'

describe Github::Issues::Events, '#list' do
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

    it { should respond_to :find }

    it "should fail to get resource without event id" do
      expect { subject.get user, repo, nil }.to raise_error(ArgumentError)
    end

    it "should get the resource" do
      subject.get user, repo, event_id
      a_get(request_path).should have_been_made
    end

    it "should get event information" do
      event = subject.get user, repo, event_id
      event.actor.id.should == event_id
      event.actor.login.should == 'octocat'
    end

    it "should return mash" do
      event = subject.get user, repo, event_id
      event.should be_a Hashie::Mash
    end
  end

  it_should_behave_like 'request failure' do
    let(:requestable) { subject.get user, repo, event_id }
  end

end # get
