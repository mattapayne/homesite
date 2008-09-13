require 'digest/md5'

module MattPayne

  class Captcha
	
    def self.valid?(random, supplied_captcha)
      actual = get_captcha_text(random)
      actual == supplied_captcha
    end
		
    def captcha_url(random)
      "http://image.captchas.net/?client=#{MattPayne::Config.captcha_username}&random=#{random}"
    end
		
    def generate_random(length=6)  
      chars = 'abcdefghjkmnpqrstuvwxyzABCDEFGHJKLMNOPQRSTUVWXYZ23456789'  
      captcha = ''
      length.times { |i| captcha << chars[rand(chars.length)] }  
      captcha  
    end  
    
    private

    def self.get_captcha_text(random, alphabet='abcdefghijklmnopqrstuvwxyz', character_count = 6)
      if character_count < 1 || character_count > 16
        raise "Character count of #{character_count} is outside the range of 1-16"
      end

      input = "#{MattPayne::Config.captcha_key}#{random}"

      if alphabet != 'abcdefghijklmnopqrstuvwxyz' || character_count != 6
        input <<  ":#{alphabet}:#{character_count}"
      end

      bytes = Digest::MD5.hexdigest(input).slice(0..(2*character_count - 1)).scan(/../)
      text = ''

      bytes.each do |byte|
        text << alphabet[byte.hex % alphabet.size].chr
      end

      text
    end
		
  end
	 
end
