# frozen_string_literal: true

RSpec.describe MeiliSearch::Client::Keys do
  before(:all) do
    @client = MeiliSearch::Client.new($URL, $API_KEY)
  end

  it 'gets the list of keys' do
    response = @client.keys
    expect(response).to be_a(Hash)
    expect(response.count).to eq(2)
    expect(response.keys).to contain_exactly('private', 'public')
    expect(response['private']).to be_a(String)
    expect(response['public']).to be_a(String)
  end

  it 'fails to get keys if public key used' do
    public_key = @client.keys['public']
    new_client = MeiliSearch::Client.new($URL, public_key)
    expect { new_client.keys }.to raise_meilisearch_http_error_with(403)
  end

  it 'fails to get keys if private key used' do
    public_key = @client.keys['private']
    new_client = MeiliSearch::Client.new($URL, public_key)
    expect { new_client.keys }.to raise_meilisearch_http_error_with(403)
  end

  it 'works with method aliases' do
    expect(@client.method(:keys) == @client.method(:get_keys)).to be_truthy
  end
end
