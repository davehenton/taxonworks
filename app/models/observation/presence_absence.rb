class Observation::PresenceAbsence < Observation

  validates :presence, inclusion: {in:  [true, false]}

end
