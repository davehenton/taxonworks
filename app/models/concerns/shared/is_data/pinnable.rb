module Shared::IsData::Pinnable 
  extend ActiveSupport::Concern

  included do
   #  include Users
  end

  def pinned?(user)
    user.pinboard_items.for_object(self.metamorphosize).count > 0
  end

end
