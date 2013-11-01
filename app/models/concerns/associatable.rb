# TODO: Please improve the documentation on these functions, since right now I have no idea what they do (or just a vague one)
module Associatable
  extend ActiveSupport::Concern


  def set_immutable(associated_klass, params)
    # we need this to find by id OR by some unique characteristic/array of characteristics
    # if not found, ERROR!
    # use where to find, given the params hash
    # CANNOT CREATE OR UPDATE

    associated_call = associated_klass.name.underscore
    associated_id = params["#{associated_klass.name.underscore}_id".to_sym]
    associated_attribute_keys = associated_klass.accessible_attributes.to_a.map{|e| e.to_sym}
    associated_attrs = params.slice(*associated_attribute_keys)

    if associated_id.blank?
      associated_query = associated_klass.where(associated_attrs)
      if associated_query.length != 1
        raise StandardError, "Cannot find associated object. #{associated_query.length} results found."
      end
      associated_obj = associated_query.first
    else
      associated_obj = associated_klass.find(associated_id)
    end

    self.send(associated_call+"=", associated_obj)
  end

  def set_associated(associated_klass, params)
    # THIS FUNCTION HAS FULL CONTROL OF CREATING THE ASSOCIATED OBJECT
    # IT CANNOT DESTROY IT THOUGH
    # IT CAN ONLY FIND BY ID

    should_delete = params[:delete].to_i == 1 ? true : false

    # Setup
    associated_call = associated_klass.name.underscore
    associated_id = params["#{associated_klass.name.underscore}_id".to_sym]
    associated_attribute_keys = associated_klass.accessible_attributes.to_a.map{|e| e.to_sym}
    associated_attrs = params.slice(*associated_attribute_keys)

    if should_delete
      # Destroy
      MY_LOG.info "DESTROY"
      self.send(associated_call+"=", nil)
    elsif associated_id.blank?
      # Create New
      MY_LOG.info "CREATE"
      associated_obj = associated_klass.new(associated_attrs)
      self.send(associated_call+"=", associated_obj)
    else
      # Update
      MY_LOG.info "UPDATE"
      associated_obj = associated_klass.find(associated_id)
      associated_obj.update_attributes(associated_attrs)
    end
  end

  def set_list(association_klass, associated_klass, list_hash)
    MY_LOG.info "LIST HASH: #{list_hash.inspect}"

    # get association function call strings from klass names
    collection_call = association_klass.name.pluralize.underscore
    associated_call = associated_klass.name.underscore

    should_clear = list_hash[:clear_all].to_i == 1

    if should_clear
      MY_LOG.info "CLEAR ALL"
      self.send(collection_call).clear
    end

    list_hash[:list].each do |params|
      MY_LOG.info params
      associated_id = params["#{associated_klass.name.underscore}_id".to_sym]
      association_id = params["#{association_klass.name.underscore}_id".to_sym]
      associated_attribute_keys = associated_klass.attribute_names.map(&:to_sym)
      association_attribute_keys = association_klass.attribute_names.map(&:to_sym)

      associated_attrs = params.slice(*associated_attribute_keys)
      association_attrs = {}
      association_attrs = params[:association].slice(*association_attribute_keys) if params[:association]
#      MY_LOG.info "============================\n#{association_attrs} #{association_attribute_keys}\n=========================="

      should_delete = params[:delete].to_i == 1 ? true : false

      if should_delete
        # Destroy
        #MY_LOG.info "DESTROY"
        association_klass.find(association_id).destroy unless association_id.blank?
      elsif association_id.blank? or should_clear
        # Create New
        #MY_LOG.info "CREATE"
        if associated_id.blank?
          #MY_LOG.info "WITH NEW ASSOCIATED"
          associated_obj = associated_klass.new(associated_attrs)
        else
          #MY_LOG.info "WITH EXISTING ASSOCIATED"
          associated_obj = associated_klass.find(associated_id)
          associated_obj.update_attributes(associated_attrs)
        end
        MY_LOG.info "SHOULD DO THIS B"
        assoc = association_klass.new(association_attrs)
        assoc.send(associated_call+"=", associated_obj)
        assoc.send("#{self.class.name.underscore}=", self)
        self.send(collection_call) << assoc
      else
        # Update
        #MY_LOG.info "UPDATE"
        assoc = association_klass.find(association_id)
        assoc.update_attributes(association_attrs)
        assoc.send(associated_call).update_attributes(associated_attrs)
      end
      MY_LOG.info "ASSOCIATION: #{assoc.inspect} #{assoc.send(associated_call).inspect} valid?: #{assoc.send(associated_call).valid?} ??: #{assoc.valid?}\n\n" if assoc
    end

  end
end
