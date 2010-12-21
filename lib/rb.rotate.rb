# encoding: utf-8
require "rb.rotate/dispatcher"

module rbRotate

    ##
    # Runs the application.
    #
    
    def self.run!
        Dispatcher::new::run!
    end
    
end
