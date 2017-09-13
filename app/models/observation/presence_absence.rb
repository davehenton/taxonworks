class Observation::PresenceAbsence < Observation

  validates :presence, :inclusion => {in:  [true, false]}

  protected

  def set_cached
  end

end
