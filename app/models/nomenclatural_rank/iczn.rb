class NomenclaturalRank::Iczn < NomenclaturalRank

  def self.group_base(rank_string)
    rank_string.match( /(NomenclaturalRank::Iczn::.+Group::).+/)
    $1
  end

end
