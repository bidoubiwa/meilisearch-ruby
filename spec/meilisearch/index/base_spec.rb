# frozen_string_literal: true

RSpec.describe MeiliSearch::Index::Base do
  before(:all) do
    @schema = {
      objectId: [:displayed, :indexed, :identifier],
      title: [:displayed, :indexed]
    }
    client = MeiliSearch::Client.new($URL, $API_KEY)
    @index_name1 = SecureRandom.hex(4)
    @index_name2 = SecureRandom.hex(4)
    @index1 = client.create_index(@index_name1)
    @index2 = client.create_index(name: @index_name2, schema: @schema)
  end

  it 'shows the index' do
    response = @index1.show
    expect(response).to be_a(Hash)
    expect(response['name']).to eq(@index_name1)
    expect(response['uid']).to eq(@index1.uid)
  end

  it 'successfully gets the schema' do
    response = @index2.schema
    expect(response).to be_a(Hash)
    expect(response['objectId']).to contain_exactly(*@schema[:objectId].map(&:to_s))
    expect(response['title']).to contain_exactly(*@schema[:title].map(&:to_s))
  end

  it 'returns nil when there is no schema' do
    response = @index1.schema
    expect(response).to be_nil
  end

  it 'updates name of index' do
    new_name = 'new name'
    response = @index1.update_name(new_name)
    expect(response).to be_a(Hash)
    expect(response['name']).to eq(new_name)
    expect(@index1.name).to eq(new_name)
  end

  it 'updates schema of index' do
    new_schema = {
      objectId: [:indexed, :identifier],
      title: [:displayed, :indexed]
    }
    response = @index2.update_schema(new_schema)
    expect(response).to be_a(Hash)
    expect(response).to have_key('updateId')
    sleep(0.1)
    skip 'waiting for next version' do
      expect(@index2.schema.to_json).to eq(new_schema.to_json)
    end
  end

  it 'deletes index' do
    expect(@index1.delete).to be_nil
    expect { @index1.show }.to raise_meilisearch_http_error_with(404)
    expect(@index2.delete).to be_nil
    expect { @index2.show }.to raise_meilisearch_http_error_with(404)
  end

  it 'fails to manipulate index object after deletion' do
    expect { @index2.name }.to raise_meilisearch_http_error_with(404)
    expect { @index2.schema }.to raise_meilisearch_http_error_with(404)
    expect { @index2.show }.to raise_meilisearch_http_error_with(404)
    expect { @index2.update_name('test') }.to raise_meilisearch_http_error_with(404)
    expect { @index2.update_schema({}) }.to raise_meilisearch_http_error_with(404)
    expect { @index2.delete }.to raise_meilisearch_http_error_with(404)
  end

  it 'works with method aliases' do
    expect(@index1.method(:show) == @index1.method(:show_index)).to be_truthy
    expect(@index1.method(:schema) == @index1.method(:get_schema)).to be_truthy
    expect(@index1.method(:update_name) == @index1.method(:update_index_name)).to be_truthy
    expect(@index1.method(:update_schema) == @index1.method(:update_index_schema)).to be_truthy
    expect(@index1.method(:delete) == @index1.method(:delete_index)).to be_truthy
  end
end
