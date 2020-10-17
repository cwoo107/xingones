# frozen_string_literal: true

class Inventory
  include ActiveModel::Attributes
  include ActiveModel::Dirty
  include ActiveModel::Serializers::JSON
  include ActiveModel::Model

  extend Enumerable
  SQUARE_API = Square::Client.new(access_token: ENV['SQUARE_TOKEN'], environment: ENV['SQUARE_ENV'])
  CATALOG_API = SQUARE_API.catalog

  attribute :id, :string
  attribute :item_data, :hash, default: {}
  attribute :catalog_v1_ids, :array_of_hashes, default: []
  attribute :variations, :array_of_hashes, default: []

  define_model_callbacks :create, :update, :save

  def self.all
    opts = { types: 'ITEM' }
    result = CATALOG_API.list_catalog(opts)
    api_result(result)
  end

  def self.find(id)
    include_related_objects = true
    result = CATALOG_API.retrieve_catalog_object(object_id: id, include_related_objects: include_related_objects)
    api_result(result)
  end

  def self.create(body)
    run_callbacks :create do
      result = CATALOG_API.upsert_catalog_object(body: body)
      api_result(result)
    end
  end

  def self.update(body)
    run_callbacks :create do
      result = CATALOG_API.upsert_catalog_object(body: body)
      api_result(result)
    end
  end

  def self.api_result(result)
    if result.success?
      result.data
    elsif result.error?
      warn result.errors
    end
  end

end

