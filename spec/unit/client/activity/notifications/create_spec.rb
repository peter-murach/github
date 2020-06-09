# encoding: utf-8

require 'spec_helper'

RSpec.describe Github::Client::Activity::Notifications, '#create' do
  let(:thread_id) { 1 }
  let(:request_path) { "/notifications/threads/#{thread_id}/subscription" }

  let(:inputs) {{
    :subscribed => true,
    :ignored => false
  }}

  before {
    subject.oauth_token = OAUTH_TOKEN
    stub_put(request_path).
      with(:body => inputs, :query => {:access_token => OAUTH_TOKEN}).
      to_return(:body => body, :status => status,
        :headers => {:content_type => "application/json; charset=utf-8"} )
  }

  after { reset_authentication_for subject }

  context "resource created successfully" do
    let(:body)  { fixture('activity/subscribed.json') }
    let(:status) { 200 }

    it 'asserts thread id presence' do
      expect { subject.create }.to raise_error(ArgumentError)
    end

    it 'creates resource' do
      subject.create thread_id, inputs
      expect(a_put(request_path).
        with(:body => inputs, :query => {:access_token => OAUTH_TOKEN})).
        to have_been_made
    end

    it 'returns the resource' do
      thread = subject.create thread_id, inputs
      expect(thread.subscribed).to be true
    end
  end
end # create
