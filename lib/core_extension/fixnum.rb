class Bignum

  BASE32_ALPHABET = [
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H',
    'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
    'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X',
    'Y', 'Z', '2', '3', '4', '5', '6', '7']
  
  #Different thant Fixnum#to_s(32). This one followes RFC-4648.
  #See - http://en.wikipedia.org/wiki/Base32 
  def to_base32
    bs32_string = ''
    bs32_number = to_i
    return BASE32_ALPHABET[0].downcase if bs32_number == 0
    while bs32_number > 0
      bs32_string += "#{BASE32_ALPHABET[bs32_number % 32]}"
      bs32_number = bs32_number / 32
    end
    bs32_string.reverse.downcase
  end
end

#DRY, how?
class Fixnum

  BASE32_ALPHABET = [
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H',
    'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
    'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X',
    'Y', 'Z', '2', '3', '4', '5', '6', '7']
  
  #Different thant Fixnum#to_s(32). This one followes RFC-4648.
  #See - http://en.wikipedia.org/wiki/Base32 
  def to_base32
    bs32_string = ''
    bs32_number = to_i
    return BASE32_ALPHABET[0].downcase if bs32_number == 0
    while bs32_number > 0
      bs32_string += "#{BASE32_ALPHABET[bs32_number % 32]}"
      bs32_number = bs32_number / 32
    end
    bs32_string.reverse.downcase
  end
end

