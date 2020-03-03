# frozen_string_literal: true

RSpec.describe MeiliSearch::Index::Settings do
  before(:all) do
    client = MeiliSearch::Client.new($URL, $API_KEY)
    clear_all_indexes(client)
    @index = client.create_index('indexUID')
  end

  after(:all) do
    @index.delete
  end

  context 'On global settings routes' do
    it 'gets default values of setting' do
      response = @index.settings
      expect(response).to be_a(Hash)
      expect(response).not_to be_empty
      expect(response.keys).to contain_exactly(
        'rankingRules',
        'distinctAttribute',
        'searchableAttributes',
        'displayedAttributes',
        'stopWords',
        'synonyms',
        'acceptNewFields'
      )
      expect(response['rankingRules']).to eq([
        'typo',
        'words',
        'proximity',
        'attribute',
        'wordsPosition',
        'exactness'
      ])
      expect(response['distinctAttribute']).to be_nil
      expect(response['searchableAttributes']).to be_nil
      expect(response['displayedAttributes']).to be_nil
      expect(response['stopWords']).to eq([])
      expect(response['synonyms']).to eq({})
      expect(response['acceptNewFields']).to be_truthy
    end

    it 'updates multiples settings at the same time' do
      response = @index.update_settings(
        rankingRules: ['asc(title)', 'typo'],
        distinctAttribute: 'title'
      )
      expect(response).to have_key('updateId')
      sleep(0.1)
      settings = @index.settings
      expect(settings['rankingRules']).to eq(['asc(title)', 'typo'])
      expect(settings['distinctAttribute']).to eq('title')
      expect(settings['stopWords']).to be_empty
    end

    it 'updates one setting without reset the others' do
      response = @index.update_settings(stopWords: ['the'])
      expect(response).to have_key('updateId')
      sleep(0.1)
      settings = @index.settings
      expect(settings['rankingRules']).to eq(['asc(title)', 'typo'])
      expect(settings['distinctAttribute']).to eq('title')
      expect(settings['stopWords']).to eq(['the'])
      expect(settings['synonyms']).to be_empty
    end

    it 'resets all settings' do
      response = @index.reset_settings
      expect(response).to have_key('updateId')
      sleep(0.1)
      settings = @index.settings
      expect(settings['rankingRules']).to eq([
        'typo',
        'words',
        'proximity',
        'attribute',
        'wordsPosition',
        'exactness'
      ])
      expect(settings['distinctAttribute']).to be_nil
      expect(settings['stopWords']).to be_empty
      expect(settings['synonyms']).to be_empty
    end
  end

  it 'works with method aliases' do
    expect(@index.method(:settings) == @index.method(:get_settings)).to be_truthy
  end
end
