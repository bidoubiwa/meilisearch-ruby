# frozen_string_literal: true

RSpec.describe MeiliSearch::Index::Base do
  before(:all) do
    @uid1 = 'UID_1'
    @uid2 = 'UID_2'
    @identifier = 'objectId'
    client = MeiliSearch::Client.new($URL, $API_KEY)
    clear_all_indexes(client)
    @index1 = client.create_index(@uid1)
    @index2 = client.create_index(uid: @uid2, identifier: @identifier)
  end

  it 'shows the index' do
    response = @index1.show
    expect(response).to be_a(Hash)
    expect(response['name']).to eq(@uid1)
    expect(response['uid']).to eq(@uid1)
    expect(response['uid']).to eq(@index1.uid)
    expect(response['identifier']).to be_nil
  end

  it 'get identifier of index if null' do
    expect(@index1.identifier).to be_nil
  end

  it 'get identifier of index if it exists' do
    expect(@index2.identifier).to eq(@identifier)
  end

  it 'get uid of index' do
    expect(@index1.uid).to eq(@uid1)
  end

  it 'updates identifier of index if not defined before' do
    new_identifier = 'id_test'
    response = @index1.update(identifier: new_identifier)
    expect(response).to be_a(Hash)
    expect(response['uid']).to eq(@uid1)
    expect(@index1.identifier).to eq(new_identifier)
  end

  it 'returns error if trying to update identifier if it is already defined' do
    new_identifier = 'id_test'
    expect {
      @index2.update(identifier: new_identifier)
    }.to raise_meilisearch_http_error_with(400)
  end

  it 'deletes index' do
    expect(@index1.delete).to be_nil
    expect { @index1.show }.to raise_meilisearch_http_error_with(404)
    expect(@index2.delete).to be_nil
    expect { @index2.show }.to raise_meilisearch_http_error_with(404)
  end

  it 'fails to manipulate index object after deletion' do
    expect { @index2.identifier }.to raise_meilisearch_http_error_with(404)
    expect { @index2.show }.to raise_meilisearch_http_error_with(404)
    expect { @index2.update(identifier: 'id_test') }.to raise_meilisearch_http_error_with(404)
    expect { @index2.delete }.to raise_meilisearch_http_error_with(404)
  end

  it 'works with method aliases' do
    expect(@index1.method(:show) == @index1.method(:show_index)).to be_truthy
    expect(@index1.method(:identifier) == @index1.method(:get_identifier)).to be_truthy
    expect(@index1.method(:update) == @index1.method(:update_index)).to be_truthy
    expect(@index1.method(:delete) == @index1.method(:delete_index)).to be_truthy
  end
end
