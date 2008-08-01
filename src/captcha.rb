require 'digest/md5'

module MattPayne

	module Captcha

		def get_text(secret, random, alphabet='abcdefghijklmnopqrstuvwxyz', character_count = 6)
		  if character_count < 1 || character_count > 16
		    raise "Character count of #{character_count} is outside the range of 1-16"
		  end

		  input = "#{secret}#{random}"

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
