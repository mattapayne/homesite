require 'net/smtp'
require 'timeout'

module MattPayne
  class GMailer
    
    class << self
      
      def default_options
        @default_options ||= {
          :smtp_server => "smtp.gmail.com", :port => 587,
          :host => "mattpayne.ca", :mail_type => "plain",
          :to => "paynmatt@gmail.com", :from => "paynmatt@gmail.com"
        }
      end
      
      def send(options)
        options = options.merge(default_options)
        if message_valid?(options)
          begin
            Timeout::timeout(10) do
              Net::SMTP.start(options[:smtp_server], options[:port], options[:host],
                options[:username], options[:password], options[:mail_type]) do |smtp|
                smtp.open_message_stream(options[:from], options[:to]) do |msg_stream|
                  msg_stream.puts "From: #{options[:from]}"
                  msg_stream.puts "To: #{options[:to]}"
                  msg_stream.puts "Subject: #{options[:subject]}"
                  msg_stream.puts
                  msg_stream.puts "#{options[:body]}"
                end
              end
            end
          rescue Timeout::Error => e
            MattPayne::AppLogger.error("Attempting to send new comment email, but a timeout occurred: #{e}")
          end
        else
          raise "Message options are invalid. Current options: #{options.inspect}."
        end
      end
      
      private

      def message_valid?(options)
        return false if options.nil? || options.empty?
        [:subject, :body, :smtp_server, :port, :host, :username, 
          :password, :mail_type, :from, :to].each do |f| 
          return false if !options.key?(f) || options[f].to_s.empty?
        end
        return true
      end
    end
      
  end
end
  