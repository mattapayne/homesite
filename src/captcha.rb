require 'digest/md5'

module MattPayne

  module Captcha
	
    def captcha_valid?(supplied_captcha)
      actual = get_captcha_text(session.delete(:captcha))
      actual == supplied_captcha
    end
		
    def captcha_url(length=6)
      session[:captcha] = generate_captcha_text
      "http://image.captchas.net/?client=#{MattPayne::Config.captcha_username}&random=#{session[:captcha]}"
    end
		
    def generate_captcha_text(length=6)  
      chars = 'abcdefghjkmnpqrstuvwxyzABCDEFGHJKLMNOPQRSTUVWXYZ23456789'  
      captcha = ''
      length.times { |i| captcha << chars[rand(chars.length)] }  
      captcha  
    end  
    
    private

    def get_captcha_text(random, alphabet='abcdefghijklmnopqrstuvwxyz', character_count = 6)
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
