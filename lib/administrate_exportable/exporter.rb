  # The BaseExporter class defines all the logic needed to export a model to CSV.
  # Its architecture make it easy to add more exporters to different models with minimum code.
  # On the children classes, all you have to do is define the attributes that will be exported on ATTRIBUTES constant.
  # Optionally, it is also possible to define the column names in case you wan't something different from the titleized method names.
  # Other than that, the children classes must implement two methods the `collection` and `presenter` method
  # The collection method will define the elements that will be exported, normally you'll use the Model#all method, but you can use scope or any other query
  # The presenter(record) method normally will instantiate the presenter for the given record, but if you don't need a presenter, simply return the actual record.
  require 'csv'

module AdministrateExportable
  class Exporter
    def self.csv(dashboard, resource_class)
      new(dashboard, resource_class).csv
    end

    def initialize(dashboard, resource_class)
      @dashboard = dashboard
      @resource_class = resource_class
    end

    def csv
      CSV.generate(headers: true) do |csv|
        csv << headers

        collection.find_each do |record|
          csv << attributes.map { |attribute| record.public_send(attribute) }
        end
      end
    end

    private

    attr_reader :dashboard, :resource_class

    def headers
      dashboard.class::COLLECTION_ATTRIBUTES.map do |attribute|
        I18n.t(
          "helpers.label.#{resource_class.name}.#{attribute}",
          default: attribute.to_s,
        ).titleize
      end
    end

    def attributes
      dashboard.class::COLLECTION_ATTRIBUTES
    end

    def collection
      relation = resource_class.default_scoped
      resource_includes = dashboard.association_includes

      return relation if resource_includes.empty?

      relation.includes(*resource_includes)
    end
  end
end
