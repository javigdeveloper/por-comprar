require "rails_helper"

RSpec.describe "HTTP Basic Authentication", type: :request do
  before do
    allow_any_instance_of(ApplicationController).to receive(:skip_basic_auth?).and_return(false)
  end

  let(:username) { ENV["BASIC_AUTH_USER"] || "admin" }
  let(:password) { ENV["BASIC_AUTH_PASSWORD"] || "supersecret" }

  it "denies access without credentials" do
    get to_buy_items_path
    expect(response).to have_http_status(:unauthorized)
  end

  it "allows access with correct credentials" do
    Item.create!(name: "Setup", status: :to_buy)

    get to_buy_items_path, headers: {
      "HTTP_AUTHORIZATION" => ActionController::HttpAuthentication::Basic.encode_credentials(username, password)
    }

    expect(response).to have_http_status(:ok)
  end
end
