# Generated via
#  `rails generate curation_concerns:work MultiVolumeWork`
require 'rails_helper'

describe CurationConcerns::Actors::MultiVolumeWorkActor do
  it 'is a BaseActor' do
    expect(described_class < ::CurationConcerns::Actors::BaseActor).to be true
  end
end
