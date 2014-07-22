require 'rails_helper'

describe 'ControlledVocabularyTerms' do

  it_behaves_like 'a_login_required_and_project_selected_controller' do 
    let(:index_path) { controlled_vocabulary_terms_path }
    let(:page_index_name) { 'Controlled Vocabulary Terms' }
  end

  describe 'GET /controlled_vocabulary_terms' do
    before { 
      sign_in_user_and_select_project 
      visit controlled_vocabulary_terms_path }
    specify 'an index name is present' do
      expect(page).to have_content('Controlled Vocabulary Terms')
    end
  end
end


