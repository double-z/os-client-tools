module Rhc
  module Rest
    class Domain
      include Rest
      attr_reader :id
      def initialize(args)
        @id = args[:id] || args["id"]
        @links = args[:links] || args["links"]
      end

      #Add Application to this domain
      def add_application(name, cartridge, scale=false)
        logger.debug "Adding application #{name} to domain #{self.id}"
        url = @@end_point + @links['ADD_APPLICATION']['href']
        method =  @links['ADD_APPLICATION']['method']
        payload = {:name => name, :cartridge => cartridge}
        timeout = nil
        if scale
          timeout = 180 # 3 minute timeout for scalable app
          payload[:scale] = true
        end
        request = RestClient::Request.new(:url => url, :method => method, :headers => @@headers, :payload => payload, :timeout => timeout)
        return send(request)
      end

      #Get all Application for this domain
      def applications
        logger.debug "Getting all applications for domain #{self.id}"
        url = @@end_point + @links['LIST_APPLICATIONS']['href']
        method =  @links['LIST_APPLICATIONS']['method']
        request = RestClient::Request.new(:url => url, :method => method, :headers => @@headers)
        return send(request)
      end

      #Update Domain
      def update(new_id)
        logger.debug "Updating domain #{self.id} to #{new_id}"
        url = @@end_point + @links['UPDATE']['href']
        method =  @links['UPDATE']['method']
        payload = {:domain_id => new_id}
        request = RestClient::Request.new(:url => url, :method => method, :headers => @@headers, :payload => payload)
        return send(request)
      end
      alias :save :update

      #Delete Domain
      def destroy(force=false)
        logger.debug "Deleting domain #{self.id}"
        url = @@end_point + @links['DELETE']['href']
        method =  @links['DELETE']['method']
        payload = {:force => force}
        request = RestClient::Request.new(:url => url, :method => method, :headers => @@headers, :payload => payload)
        return send(request)
      end
      alias :delete :destroy
    end
  end
end
