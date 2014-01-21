class TaxonNameRelationship::Typification::Genus::OriginalDesignation < TaxonNameRelationship::Typification::Genus

  # left side
  def self.valid_subject_ranks
    SPECIES_RANK_NAMES_ICZN
  end

  # right_side
  def self.valid_object_ranks
    GENUS_RANK_NAMES_ICZN
  end

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships + self.collect_descendants_to_s(
        TaxonNameRelationship::Typification::Genus::Tautonomy,
        TaxonNameRelationship::Typification::Genus::Monotypy) + self.collect_to_s(
        TaxonNameRelationship::Typification::Genus,
        TaxonNameRelationship::Typification::Genus::Tautonomy,
        TaxonNameRelationship::Typification::Genus::Monotypy,
        TaxonNameRelationship::Typification::Genus::SubsequentDesignation)
  end

  def self.subject_relationship_name
    'type species by original designation'
  end

  def self.assignment_method
    :type_species_by_original_designation 
  end

end
