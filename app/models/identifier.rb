# The information that can be use to differentiate concepts.
#
# Note this definition is presently very narrow, and that an identifier
# can in practice be used for a lot more than differentiation (i.e.
# it can often be resolved etc.).
#
# In TW identifiers are either global, in which case they
# are subclassed by type, and do not include a namespace,
# or local, in which case they have a namespace.
#
# !! Identifiers should always be created in the context of their parents see spec/lib/identifier_spec.rb for examples  !!
#
# @!attribute identifier
#   @return [String]
#   The string identifying the object.  Must be unique within the Namespace if provided.
#   Same as http://rs.tdwg.org/dwc/terms/catalogNumber, but broadened in scope to be used for any data.
#
# @!attribute type
#   @return [String]
#   The Rails STI subclass of this identifier.
#
# @!attribute namespace_id
#   @return [Integer]
#   The Namespace for this identifier.
#
# @!attribute project_id
#   @return [Integer]
#   The project ID.
#
# @!attribute cached
#   @return [String]
#   The full identifier, for display, i.e. namespace + identifier (local), or identifier (global).
#
# @!attribute identifier_object_id
#   @return [Integer]
#   The id of the identified object, used in a polymorphic relationship.
#
# @!attribute identifier_object_id
#   @return [String]
#   The type of the identified object, used in a polymorphic relationship.
#
class Identifier < ApplicationRecord

  acts_as_list scope: [:project_id, :identifier_object_id, :identifier_object_type]

  include Housekeeping
  include Shared::IsData
  include Shared::DualAnnotator
  include Shared::PolymorphicAnnotator
  polymorphic_annotates('identifier_object')

  after_save :set_cached
  
  belongs_to :namespace # only applies to Identifier::Local, here for create purposes

  # Please DO NOT include the following:
  #   validates :identifier_object, presence: true
  #   validates_presence_of :identifier_object_type, :identifier_object_id
  validates_presence_of :type, :identifier

  # TODO: DRY to IsData? Test. 
  scope :with_type_string, -> (base_string) {where('type LIKE ?', "#{base_string}")}

  def self.find_for_autocomplete(params)
    where('identifier LIKE ?', "#{params[:term]}%")
  end

  def self.prototype_identifier(project_id, created_by_id)
    identifiers = Identifier.where(project_id: project_id, created_by_id: created_by_id).limit(1)
    identifiers.empty? ? '12345678' : identifiers.last.identifier
  end

  def type_name
    self.class.name.demodulize.downcase
  end

  protected

  def set_cached
  end

end
