require 'omniauth'
require 'xmlsimple'

module OmniAuth
  module Strategies
    class Alephx
      include OmniAuth::Strategy

      #required
      option :url # :url => "http://aleph.ugent.be/X"
      option :library # :library => "rug50"

      #only for test purpose (if you do not specify the option :form, a form will be created, using these options)
      option :title_form, "Aleph authentication"
      option :label_password,:password
      option :label_username,:username
      option :label_submit, "submit"

      @user_info = {}

      uid {
        @user_info[:bor_id]
      }
      info {
        { 
          :name => @user_info[:bor_id],
          :email => @user_info[:email]
        }
      }
      credentials {
        {}
      }
      extra {
        @user_info
      }

      def request_phase
        
        form = OmniAuth::Form.new(:title => options[:title_form], :url => callback_path)
        form.text_field options[:label_username],:username
        form.password_field options[:label_password],:password
        form.button options[:label_submit]
        form.to_response

      end

      def callback_phase          

        if missing_credentials?
          session['omniauth.alephx.error'] = :missing_credentials
          return redirect(request_path)
        end

        begin

          params = request.params
          username = params['username']
          password = params['password']         
          
          unless bor_auth(username,password)                
            session['omniauth.alephx.error'] = :invalid_credentials
            return redirect(request_path)
          end

        rescue Exception => e
          session['omniauth.alephx.error'] = :invalid_credentials
          return redirect(request_path)
        end

        super
      end

      def bor_auth(username,password)
      
        uri = URI.parse(options[:url]+"?"+{
          :op => "bor-auth",
          :bor_id => username,
          :verification => password,
          :library => options[:library]
        }.to_query)
        http = Net::HTTP.new uri.host,uri.port
        if uri.scheme == "https"
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
          http.use_ssl = true
        end
        res = http.request(Net::HTTP::Get.new(uri.request_uri))

        document = XmlSimple.xml_in(res.body,{ 'ForceArray' => false })
  
        return false if document['error']

        @user_info = {
          :bor_id => username,
          :name => document['z303']['z303-name'],
          :email => document['z304']['z304-email-address']
        }          

        return true

      end   
      def missing_credentials?
        request['username'].nil? or request['username'].empty? or request['password'].nil? or request['password'].empty?
      end
    end
  end
end
