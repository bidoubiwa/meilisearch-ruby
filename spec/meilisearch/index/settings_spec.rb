# frozen_string_literal: true

RSpec.describe MeiliSearch::Index::Settings do
  before(:context) do
    client = MeiliSearch::Client.new($URL, $API_KEY)
    clear_all_indexes(client)
    @index = client.create_index('indexUID')
  end

  after(:context) do
    @index.delete
  end

  let(:default_ranking_rules) {
    [
      'typo',
      'words',
      'proximity',
      'attribute',
      'wordsPosition',
      'exactness'
    ]
  }

  let(:settings_keys) {
    [
      'rankingRules',
        'distinctAttribute',
        'searchableAttributes',
        'displayedAttributes',
        'stopWords',
        'synonyms',
        'acceptNewFields'
    ]
  }

  context 'On global settings routes' do
    it 'gets default values of settings' do
      response = @index.settings
      expect(response).to be_a(Hash)
      expect(response.keys).to contain_exactly(*settings_keys)
      expect(response['rankingRules']).to eq(default_ranking_rules)
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
      expect(settings['rankingRules']).to eq(default_ranking_rules)
      expect(settings['distinctAttribute']).to be_nil
      expect(settings['stopWords']).to be_empty
      expect(settings['synonyms']).to be_empty
    end
  end

  context 'On ranking-rules sub-routes' do
    let(:ranking_rules) { ['asc(title)', 'words', 'typo'] }

    it 'gets default values of ranking rules' do
      response = @index.ranking_rules
      expect(response).to eq(default_ranking_rules)
    end

    it 'updates ranking rules' do
      response = @index.update_ranking_rules(ranking_rules)
      expect(response).to have_key('updateId')
      sleep(0.1)
      expect(@index.ranking_rules).to eq(ranking_rules)
    end

    it 'resets ranking rules' do
      response = @index.reset_ranking_rules
      expect(response).to have_key('updateId')
      sleep(0.1)
      expect(@index.ranking_rules).to eq(default_ranking_rules)
    end
  end

  context 'On distinct-attribute sub-routes' do
    let(:distinct_attribute) { 'title' }

    it 'gets default values of distinct attribute' do
      response = @index.distinct_attribute
      expect(response).to be_nil
    end

    it 'updates distinct attribute' do
      response = @index.update_distinct_attribute(distinct_attribute)
      expect(response).to have_key('updateId')
      sleep(0.1)
      expect(@index.distinct_attribute).to eq(distinct_attribute)
    end

    it 'resets distinct attribute' do
      response = @index.reset_distinct_attribute
      expect(response).to have_key('updateId')
      sleep(0.1)
      expect(@index.distinct_attribute).to be_nil
    end
  end

  context 'On searchable-attributes sub-routes' do
    let(:searchable_attributes) { ['title', 'description'] }

    it 'gets default values of searchable attributes' do
      response = @index.searchable_attributes
      expect(response).to be_a(Array)
      expect(response).to be_empty
    end

    it 'updates searchable attributes' do
      response = @index.update_searchable_attributes(searchable_attributes)
      expect(response).to have_key('updateId')
      sleep(0.1)
      expect(@index.searchable_attributes).to eq(searchable_attributes)
    end

    it 'resets searchable attributes' do
      response = @index.reset_searchable_attributes
      expect(response).to have_key('updateId')
      sleep(0.1)
      expect(@index.get_update_status(response['updateId'])['status']).to eq('processed')
    end

  end

  context 'On displayed-attributes sub-routes' do
    let(:displayed_attributes) { ['title', 'description'] }

    it 'gets default values of displayed attributes' do
      response = @index.displayed_attributes
      expect(response).to be_a(Array)
      expect(response).to be_empty
    end

    it 'updates displayed attributes' do
      response = @index.update_displayed_attributes(displayed_attributes)
      expect(response).to have_key('updateId')
      sleep(0.1)
      expect(@index.displayed_attributes).to eq(displayed_attributes)
    end

    it 'resets displayed attributes' do
      response = @index.reset_displayed_attributes
      expect(response).to have_key('updateId')
      sleep(0.1)
      expect(@index.get_update_status(response['updateId'])['status']).to eq('processed')
    end
  end

  context 'On accept-new-fields sub-routes' do
    it 'gets default values of acceptNewFields' do
      expect(@index.accept_new_fields).to be_truthy
    end

    it 'adds searchable or display attributes when truthy' do
      @index.update_searchable_attributes(['title', 'description'])
      sleep(0.1)
      @index.update_displayed_attributes(['title', 'description'])
      sleep(0.1)
      @index.add_documents({id: 1, title: 'Test', comment: 'comment test'})
      sleep(0.1)
      sa = @index.searchable_attributes
      da = @index.displayed_attributes
      expect(sa).to contain_exactly('title', 'description', 'comment')
      expect(da).to contain_exactly('title', 'description', 'comment')
      @index.update_searchable_attributes([])
      sleep(0.1)
      @index.update_displayed_attributes([])
      sleep(0.1)
      @index.delete_all_documents
      sleep(0.1)
    end

    it 'updates displayed attributes' do
      response = @index.update_accept_new_fields(false)
      expect(response).to have_key('updateId')
      sleep(0.1)
      expect(@index.accept_new_fields).to be_falsy
    end

    it 'does not add searchable or display attributes when falsy' do
      @index.update_searchable_attributes(['title', 'description'])
      sleep(0.1)
      @index.update_displayed_attributes(['title', 'description'])
      sleep(0.1)
      @index.add_documents({id: 1, title: 'Test', comment: 'comment test'})
      sleep(0.1)
      sa = @index.searchable_attributes
      da = @index.displayed_attributes
      expect(sa).to contain_exactly('title', 'description')
      expect(da).to contain_exactly('title', 'description')
    end
  end

  context 'Index with identifier' do
    let(:index_with_id) { client.create_index(uid: 'indexUID', identifier: 'id') }

    it 'gets the default values of settings' do
      response = index_with_ids.settings
      expect(response).to be_a(Hash)
      expect(response.keys).to contain_exactly(*settings_keys)
      expect(response['rankingRules']).to eq(default_ranking_rules)
      expect(response['distinctAttribute']).to be_nil
      expect(response['searchableAttributes']).to eq(['id'])
      expect(response['displayedAttributes']).to eq(['id'])
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
      expect(settings['rankingRules']).to eq(default_ranking_rules)
      expect(settings['distinctAttribute']).to be_nil
      expect(settings['stopWords']).to be_empty
      expect(settings['synonyms']).to be_empty
    end
  end

  context 'Manipulation of searchable/displayed attributes with the identifier' do
    it 'does not add document when there is no id' do
      @index.update_searchable_attributes([])
      @index.update_displayed_attributes([])
      sleep(0.1)
      response = @index.add_documents({ title: 'Test' })
      sleep(0.1)
      expect(@index.get_update_status(response['updateId'])['status']).to eq('failed')
    end

    it 'adds documents when there is id' do
      @index.update_searchable_attributes([])
      @index.update_displayed_attributes([])
      sleep(0.1)
      response = @index.add_documents({ objectId: 1, title: 'Test' })
      sleep(0.1)
      expect(@index.get_update_status(response['updateId'])['status']).to eq('processed')
    end
  end

  it 'works with method aliases' do
    expect(@index.method(:settings) == @index.method(:get_settings)).to be_truthy
    expect(@index.method(:ranking_rules) == @index.method(:get_ranking_rules)).to be_truthy
    expect(@index.method(:distinct_attribute) == @index.method(:get_distinct_attribute)).to be_truthy
    expect(@index.method(:searchable_attributes) == @index.method(:get_searchable_attributes)).to be_truthy
    expect(@index.method(:displayed_attributes) == @index.method(:get_displayed_attributes)).to be_truthy
    expect(@index.method(:accept_new_fields) == @index.method(:get_accept_new_fields)).to be_truthy
  end
end
