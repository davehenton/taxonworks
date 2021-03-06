json.extract! collection_object, :id, :total, :preparation_type_id, :collecting_event_id, :repository_id, :type,
  :buffered_collecting_event, :buffered_determinations, :buffered_other_labels, 
  :ranged_lot_category_id, :deaccessioned_at, :deaccession_reason,
  :contained_in, :created_by_id, :updated_by_id, :project_id, :created_at, :updated_at

json.partial! '/shared/data/all/metadata', object: collection_object 

json.identifier_tag collection_object_identifier_tag(collection_object)
