
class Hash
  
  #Expects a block with 2 arguments return an array of exactly size 2 with
  #first element being key and next value.
  #Example:
  #    hash = { 1 => 10, 2 => 20 }
  #    hash.hmap { |k,v| [ k*4, v+50] }
  #    { 4 => 60, 8 => 70 }
  #TODO: Make also accept like <tt>hash.hmap { |k,v| { k*4 => v+50 } }</tt>, code may
  #not be very optimised then though.
  #TODO: Give a better example.
  #@return [Hash] Just what Hash#map should have done.
  #Credit: Comes from my own code in Kopal::HomeController#index
  def hmap
    Hash[*(self.map { |k,v| yield k,v }.flatten)]
  end
end

