#== Designer
#Designer is a very simple and easy replacement for Rails fixtures.
#It's just like creating model records directly using ModelClass, but using
#designer you can name the rows just like fixtures.
#
#== Example Usage
#* Create a new row - <tt>Designer.model_name(row_name) do |row|
#       row.field_name = "value"
#      end</tt>
#* Get a row - <tt>Designer.model_name(row_name)</tt>
#
#Advantage of Designer over creating model records directly.
#* Gives a name to a row.
class Designer
  @@records = {}
  
  def self.method_missing method, *args
    m = method.to_sym
    raise ArgumentError, 
      "Name for row is required. You may create a record directly using " +
      "ModelClass.new(), if you don't need a named row." if args[0].blank?
    if block_given?
      if args[1].is_a? Hash and !args[1][:class].blank?
        classname = args[1][:class].to_s.constantize
      else
        classname = method.to_s.camelize.constantize
      end
      n = classname.new
      yield n
      n.save!
      @@records[m] = {} unless @@records[m].is_a? Hash
      @@records[m][args[0]] = n
    else
      raise NameError, "Can not find instance of #{method.to_s.camelize} for " + 
        "name \"#{args[0]}\"" if @@records[m][args[0]].blank?
      return @@records[m][args[0]].reload
    end
  end
  
end

Dir[RAILS_ROOT + '/test/designer/*_designer.rb'].sort.each { |f|
  #puts "Designer: requiring #{f}"
  require f
}

