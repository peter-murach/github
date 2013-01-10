# encoding: utf-8

require 'spec_helper'

describe Github::PullRequests, '#update' do
  let(:user)   { 'peter-murach' }
  let(:repo)   { 'github' }
  let(:number) { 1347 }
  let(:request_path) { "/repos/#{user}/#{repo}/pulls/#{number}" }
  let(:inputs) {
    {
      "title" => "new title",
      "body" => "updated body",
      "state" => "open",
      "unrelated" => true
    }
  }

  before {
    stub_patch(request_path).with(inputs.except('unrelated')).
      to_return(:body => body, :status => status,
      :headers => {:content_type => "application/json; charset=utf-8"})
  }

  after { reset_authentication_for(subject) }

  context "resouce updateed" do
    let(:body)   { fixture('pull_requests/pull_request.json') }
    let(:status) { 201 }

    it "should create resource successfully" do
      subject.update user, repo, number, inputs
      a_patch(request_path).with(inputs).should have_been_made
    end

    it "should return the resource" do
      pull_request = subject.update user, repo, number, inputs
      pull_request.should be_a Hashie::Mash
    end

    it "should get the pull_request information" do
      pull_request = subject.update user, repo, number, inputs
      pull_request.title.should == 'new-feature'
    end
  end

  it_should_behave_like 'request failure' do
    let(:requestable) { subject.update user, repo, number, inputs }
  end

end # update
