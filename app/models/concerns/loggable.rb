module Loggable
  extend ActiveSupport::Concern

  attr_accessor :log_source, :log_documentation, :log_user

  included do
    #  attr_accessible :log_source, :log_documentation, :log_user

    after_destroy {|record| log_change(record, "destroy") }
    after_update {|record| log_change(record, "update") }
    after_create {|record| log_change(record, "create") }

    self.sequence_name = "object_id_seq"
  end

  module ClassMethods
    def logged_new(params = nil, user = nil, source = nil, documentation = nil)
      params = self.clean_params(params)
      params[:log_source] = source
      params[:log_documentation] = documentation
      params[:log_user] = user
      self.new(params)
    end

    def clean_params(params)
      #allowed_attribute_list = self.attribute_names.map(&:to_sym) + self.attribute_names.map(&:to_s)
      #params ? params.slice(*allowed_attribute_list) : nil
      params
    end
  end

  def logged_update(params = nil,  user = nil, source = nil, documentation = nil)
    params = self.class.clean_params(params)
    params[:log_source] = source
    params[:log_documentation] = documentation
    params[:log_user] = user

    self.update(params)
  end

  def latest_source
    r = ChangeLog.recent(self.id).with_source
    #MY_LOG.info "r: #{r.to_a}"
    r.first.source unless r.empty?
  end

  def latest_documentation
    r = ChangeLog.recent(self.id).with_documentation
    r.first.documentation unless r.empty?
  end

  def latest_change
    r = ChangeLog.recent(self.id)
    r.first unless r.empty?
  end

  private

  def log_change(record, action_type)
    c = ChangeLog.new(model_id: record.id, action_type: action_type, source_id: record.log_source ? record.log_source.id : nil, documentation_id: record.log_documentation ? record.log_documentation.id : nil, timestamp: Time.zone.now(), user_id: record.log_user ? record.log_user.id : nil)
    c.save
  end

end