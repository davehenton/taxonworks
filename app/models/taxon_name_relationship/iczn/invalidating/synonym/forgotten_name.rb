class TaxonNameRelationship::Iczn::Invalidating::Synonym::ForgottenName < TaxonNameRelationship::Iczn::Invalidating::Synonym

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships + self.collect_descendants_and_itself_to_s(
        TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective) + self.collect_to_s(
        TaxonNameRelationship::Iczn::Invalidating::Synonym,
        TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective,
        TaxonNameRelationship::Iczn::Invalidating::Synonym::Subjective,
        TaxonNameRelationship::Iczn::Invalidating::Synonym::FamilyBefore1961,
        TaxonNameRelationship::Iczn::Invalidating::Synonym::Suppression)
  end

  def self.subject_relationship_name
    'nomen oblitum'
  end

  def self.object_relationship_name
    'nomen protectum'
  end

  def self.nomenclatural_priority
    :reverse
  end

  def self.assignment_method
    # aus.iczn_forgotten_name = bus
    :iczn_forgotten_name
  end

  # as.
  def self.inverse_assignment_method
    # bus.set_as_iczn_forgotten_name_of(aus)
    :set_as_iczn_forgotten_name_of
  end

end
