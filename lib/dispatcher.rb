# encoding: utf-8

require "lib/configuration"
require "lib/state"

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
            
            # Removes orhpans
            Storage::remove_orphans!
            
            # Saves state file
            State::save!
        end
        
    end    
    
end
