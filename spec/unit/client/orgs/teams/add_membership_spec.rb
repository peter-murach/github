# encoding: utf-8

require 'spec_helper'

RSpec.describe Github::Client::Orgs::Teams, '#add_membership' do
  let(:team_id) { 1 }
  let(:user) { 'peter-murach' }
  let(:request_path) { "/teams/#{team_id}/memberships/#{user}" }

  before do
    stub_put(request_path).to_return(body: body, status: status,
      headers: {content_type: "application/json; charset=utf-8"})
  end

  after { reset_authentication_for(subject) }

  context "resouce added" do
    let(:status) { 200 }

    context 'invalid arguments' do
      let(:body) {''}

      it { expect { subject.add_membership }.to raise_error(ArgumentError)}

      it "fails to add resource if 'team_id' input is nil" do
        expect { subject.add_membership nil, user }.to raise_error(ArgumentError)
      end

      it "fails to add resource if 'user' input is nil" do
        expect { subject.add_membership team_id, nil }.to raise_error(ArgumentError)
      end
    end

    context "affiliated resouce added" do
      let(:body) { fixture('orgs/add_affiliated_member.json') }

      it "adds resource successfully" do
        response = subject.add_membership team_id, user
        expect(a_put(request_path)).to have_been_made
        expect(response.state).to eq('active')
      end

    end

    context "unaffiliated resouce added" do
      let(:body) { fixture('orgs/add_unaffiliated_member.json') }

      it "adds resource successfully" do
        response = subject.add_membership team_id, user
        expect(a_put(request_path)).to have_been_made
        expect(response.state).to eq('pending')
      end
    end
  end

  it_should_behave_like 'request failure' do
    let(:requestable) { subject.add_membership team_id, user }
  end
end # add_membership
