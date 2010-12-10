# encoding: utf-8
require "configuration"

module RotateAlternative

    ##
    # Dispatches all operations.
    #
    
    class Dispatcher
        
        ##
        # Runs the rotate session.
        #
        
        def run
            # Reads configuration file
            Configuration::read("./rotate.yaml")
            
            # Process
            Configuration::each_directory do |directory|
                directory.rotate!
            end
        end
    end    
    
end
