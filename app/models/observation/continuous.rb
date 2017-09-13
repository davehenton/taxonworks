class Observation::Continuous < Observation

  validates_presence_of :continuous_value

  protected

  def set_cached
  end

end
