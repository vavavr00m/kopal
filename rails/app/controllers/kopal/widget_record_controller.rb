class Kopal::WidgetRecordController < Kopal::ApplicationController

  #TODO: Make this always return a JSON and should accept and return multiple records in one go.
  def show
    @record = Kopal::ProfileStore.find_by_widget_key_and_record_name(params[:widget_key], params[:name])
    if @record
      return unless valid_request_on_scope?(@record, :show)
      render :text => @record.record_text
    else
      #NOTE: It returns text of length 1 containing whitespace.
      render :nothing => true, :status => 404
    end
  end

  #OPTIMIZE: Need this method?
  def create
    @record = Kopal::ProfileStore.new :widget_key => params[:widget_key],
      :record_name => params[:name],
      :record_text => params[:value],
      :scope => params[:scope]
    return unless valid_request_on_scope?(@record, :create)
    if @record.save
      render :text => @record.record_text
    else
      logger.error "[Profile Store] Saving failed for Record##{@record.id} with errors - #{@record.errors.full_messages}"
      render :nothing => true, :status => :unprocessable_entity #422
    end
  end

  def update
    @record = Kopal::ProfileStore.find_or_initialize_by_widget_key_and_record_name(params[:widget_key], params[:name])
    return unless valid_request_on_scope?(@record, :update)
    @record.record_text = params[:value]
    @record.scope = params[:scope] if params[:scope].present?
    if @record.save
      render :text => @record.record_text
    else
      logger.error "[Profile Store] Saving failed for Record##{@record.id} with errors - #{@record.errors.full_messages}"
      render :nothing => true, :status => :unprocessable_entity #422
    end
  end

  def destroy
    @record = Kopal::ProfileStore.find_by_widget_key_and_record_name(params[:widget_key], params[:name])
    if @record
      return unless valid_request_on_scope?(@record, :destroy)
      if @record.destroy
        render :nothing => true, :status => 200
      else
        render :nothing => true, :status => :unprocessable_entity #422
      end
    else
      render :noting => true, :status => 404
    end
  end

private

  def valid_request_on_scope? record, action
    record.valid? #initialise scope if not already
    scope = record.scope.to_i
    case scope
    when 0 #401 Unauthorized
      render :text => scope, :status => :unauthorized and return false unless @profile_user.signed?
    when 1
      render :text => scope, :status => :unauthorized and return false unless @profile_user.signed? if
        [:create, :update, :destroy].include? action
    when 2
    end
    return true
  end
  
end