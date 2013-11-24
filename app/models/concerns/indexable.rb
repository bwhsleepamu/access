module Indexable
  extend ActiveSupport::Concern

  included do
    scope :page_per, lambda { |params| page(params[:page] ? params[:page] : 1).per(params[:per_page] == "all" ? nil : params[:per_page]) }
  end

  module ClassMethods
    def search_by_terms(search_terms)
      #search_scope = scoped
      #search_terms.each{|search_term| search_scope = search_scope.search(search_term) }
      #
      #search_scope

      all.search(search_terms)
    end

    def set_order(params, default)
      (params_column, params_direction) = params.to_s.strip.downcase.split(' ')
      (default_column, default_direction) = default.to_s.strip.downcase.split(' ')

      default_direction = (default_direction.blank? ? "asc" : default_direction)
      direction = (params_direction.blank? ? default_direction : params_direction)

      order_column = column_names.collect { |column_name| "#{column_name}" }.include?(params_column) ? params_column : default_column

      order_by = "#{table_name}.#{order_column} #{direction}"

      order(order_by)
    end

    def scrub_order(order, default_column)
      (params_column, params_direction) = params.to_s.strip.downcase.split(' ')
      direction = (params_direction == 'desc' ? 'desc' : 'asc')
      order_column = column_names.collect { |column_name| "#{column_name}" }.include?(params_column) ? params_column : default_column


    end

    def search_scope(fields, term)
      term = "%#{term.downcase.split(' ').join('%')}%"

      args = []
      query = " "
      join_list = []

      fields.each do |field|
        if field.is_a?(Hash)
          join_list << field[:join] unless join_list.include? field[:join]
          table_name = field[:join].to_s.pluralize
          column = field[:column]
        else
          table_name = self.table_name
          column = field
        end

        if query.present?
          query += " or "
        end

        query += "lower(#{table_name}.#{column}) like ?"
        args += [term]
      end

      #raise StandardError, args
      joins(join_list).where(query, *args)
    end
  end
end
