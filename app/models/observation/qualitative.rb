class Observation::Qualitative < Observation

  belongs_to :character_state

  validates_presence_of :character_state

  protected

  def set_cached
  end

end
