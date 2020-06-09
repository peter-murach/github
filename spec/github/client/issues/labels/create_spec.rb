# encoding: utf-8

require 'spec_helper'

describe Github::Client::Issues::Labels, '#create' do
  let(:user)   { 'peter-murach' }
  let(:repo)   { 'github' }
  let(:request_path) { "/repos/#{user}/#{repo}/labels" }
  let(:inputs) {
    {
      "name" => "API",
      "color" => "FFFFFF",
    }
  }

  before {
    stub_post(request_path).with(body: inputs).
      to_return(:body => body, :status => status,
      :headers => {:content_type => "application/json; charset=utf-8"})
  }

  after { reset_authentication_for(subject) }

  context "resouce created" do
    let(:body) { fixture('issues/label.json') }
    let(:status) { 200 }

    it "should fail to create resource if 'name' input is missing" do
      expect {
        subject.create user, repo, inputs.except('name')
      }.to raise_error(Github::Error::RequiredParams)
    end

    it "should fail to create resource if 'color' input is missing" do
      expect {
        subject.create user, repo, inputs.except('color')
      }.to raise_error(Github::Error::RequiredParams)
    end

    it "should create resource successfully" do
      subject.create user, repo, inputs
      expect(a_post(request_path).with(body: inputs)).to have_been_made
    end

    it "should return the resource" do
      label = subject.create user, repo, inputs
      expect(label).to be_a Github::ResponseWrapper
    end

    it "should get the label information" do
      label = subject.create user, repo, inputs
      expect(label.name).to eq 'bug'
    end
  end

  it_should_behave_like 'request failure' do
    let(:requestable) { subject.create user, repo, inputs }
  end
end # create
