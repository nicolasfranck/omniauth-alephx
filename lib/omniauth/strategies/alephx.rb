require 'omniauth'
require 'xmlsimple'
require 'uri'

module OmniAuth
  module Strategies
    class Alephx
      include OmniAuth::Strategy

      #required
      option :url # :url => "http://aleph.ugent.be/X"
      option :library # :library => "rug50"

      #only for test purpose (if you do not specify the option :form, a form
      #will be created, using these options)
      option :title_form, "Aleph authentication"
      option :label_password,:password
      option :label_username,:username
      option :label_submit, "submit"

      class << self
        attr_accessor :filters, :on_error

        def add_filter(&block)
          @filters ||= []
          @filters << block
        end
      end

      uid {
        user_info[:bor_id]
      }
      info {
        i = {}
        [:name, :email].each do |key|
          i[key] = user_info[key] if user_info[key].is_a? String
        end
        i
      }
      credentials {
        {}
      }
      extra {
        {}
      }

      def user_info
        @user_info ||= {}
      end

      def request_phase
        form = OmniAuth::Form.new(:title => options[:title_form], :url => callback_path)
        form.text_field options[:label_username],:username
        form.password_field options[:label_password],:password
        form.button options[:label_submit]
        form.to_response
      end

      def callback_phase
        params = request.params

        rp = script_name + request_path+"?"+{ :username => params['username'] }.to_query

        if missing_credentials?
          session['omniauth.alephx.error'] = :missing_credentials
          self.class.on_error.call(:missing_credentials) unless self.class.on_error.nil?
          return redirect(rp)
        end

        begin

          unless self.class.filters.nil?
            self.class.filters.each do |filter|
              filter.call(params)
            end
          end

          username = params['username']
          password = params['password']

          unless bor_auth(username,password)
            session['omniauth.alephx.error'] = :invalid_credentials
            self.class.on_error.call(:invalid_credentials) unless self.class.on_error.nil?
            return redirect(rp)
          end

        rescue Exception => e
          session['omniauth.alephx.error'] = :invalid_credentials
          self.class.on_error.call(:invalid_credentials) unless self.class.on_error.nil?
          return redirect(rp)
        end

        session.delete('omniauth.alephx.error')

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
          # user pwd to communicate with aleph (cannot extract cas username or
          # barcode from alephx!)
          :bor_id => document['z303']['z303-id'],
          :name => document['z303']['z303-name'],
          :email => document['z304']['z304-email-address'],
          :doc => document
        }

        return true
      end

      def missing_credentials?
        request['username'].nil? or request['username'].empty? or request['password'].nil? or request['password'].empty?
      end
    end
  end
end
