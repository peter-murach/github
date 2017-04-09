# encoding: utf-8

require 'spec_helper'

describe Github::Client::Authorizations, '#create' do
  let(:basic_auth)   { 'login:password' }
  let(:host)         { "https://api.github.com" }
  let(:inputs)       { {scopes: ['repo'], note: 'admin script' } }
  let(:request_path) { "/authorizations" }

  subject { described_class.new(basic_auth: basic_auth) }

  before do
    stub_post(request_path, host).to_return(body: body, status: status,
      headers: {content_type: 'application/json; charset=utf-8'})
  end

  context 'when user creates token' do
    let(:body) { fixture('auths/authorization.json') }
    let(:status) { 201 }

    it "fails to get resource without basic authentication" do
      reset_authentication_for subject
      expect { subject.create }.to raise_error(ArgumentError)
    end

    it "creates resource successfully" do
      subject.create inputs
      a_post(request_path, host).with(body: inputs).should have_been_made
    end

    it "returns the resource" do
      authorization = subject.create inputs
      authorization.should be_a Github::ResponseWrapper
    end

    it "fails without a note parameter" do
      expect {
        subject.create scopes: ['repos']
      }.to raise_error(Github::Error::RequiredParams,
                       /Required parameters are: note/)
    end

    it "gets the authorization information" do
      authorization = subject.create inputs
      authorization.token.should == 'abc123'
    end
  end

  it_should_behave_like 'request failure' do
    let(:requestable) { subject.create inputs }
  end
end # create
