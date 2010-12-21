# encoding: utf-8
require "rb.rotate/dispatcher"

module RbRotate

    ##
    # Runs the application.
    #
    
    def self.run!
        Dispatcher::new::run!
    end

    ##
    # Installs the application.
    #
    
    def self.install!
        Dispatcher::new::install!
    end
    
    ##
    # Prints out the system name.
    #
    
    def self.sysname!
        Dispatcher::new::sysname!
    end
    
end
