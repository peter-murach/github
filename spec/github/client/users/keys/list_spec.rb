# encoding: utf-8

require 'spec_helper'

describe Github::Client::Users::Keys, '#list' do
  let(:key_id) { 1 }

  before {
    subject.oauth_token = OAUTH_TOKEN
    stub_get(request_path).with(:query => { :access_token => "#{OAUTH_TOKEN}"}).
      to_return(:body => body, :status => status,
      :headers => {:content_type => "application/json; charset=utf-8"})
  }

  after { reset_authentication_for(subject) }

  context "resource found for an authenticated user" do
    let(:request_path) { "/user/keys" }
    let(:body) { fixture('users/keys.json') }
    let(:status) { 200 }

    it { is_expected.to respond_to :all }

    it "should get the resources" do
      subject.list
      expect(a_get(request_path).with(:query => { :access_token => "#{OAUTH_TOKEN}"})).
        to have_been_made
    end

    it_should_behave_like 'an array of resources' do
      let(:requestable) { subject.list }
    end

    it "should get keys information" do
      keys = subject.list
      expect(keys.first.id).to eq key_id
    end

    it "should yield to a block" do
      yielded = []
      result = subject.list { |obj| yielded << obj }
      expect(yielded).to eq result
    end

    it_should_behave_like 'request failure' do
      let(:requestable) { subject.list }
    end
  end

  context "resource found for a user" do
    let(:user) { 'peter-murach' }
    let(:body) { fixture('users/keys.json') }
    let(:status) { 200 }
    let(:request_path) { "/users/#{user}/keys" }

    it "should get the resources" do
      subject.list :user => user
      expect(a_get(request_path).with(:query => { :access_token => "#{OAUTH_TOKEN}"})).
        to have_been_made
    end

    it_should_behave_like 'an array of resources' do
      let(:requestable) { subject.list :user => user }
    end

    it "should get keys information" do
      keys = subject.list :user => user
      expect(keys.first.id).to eq key_id
    end

    it "should yield to a block" do
      yielded = []
      result = subject.list(:user => user) { |obj| yielded << obj }
      expect(yielded).to eq result
    end
  end
end # list
