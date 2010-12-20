# encoding: utf-8

require "rotate-alternative/configuration"
require "rotate-alternative/state"
require "rotate-alternative/storage"
require "rotate-alternative/log"

module RotateAlternative

    ##
    # Dispatches all operations.
    #
    
    class Dispatcher
        
        ##
        # Runs the rotate session.
        #
        
        def run!
            # Reads configuration file
            Configuration::read("./rotate.yaml")
            log "Configuration file loaded."
            
            # Process
            log "Start of processing."
            Configuration::each_directory do |directory|
                begin
                    directory.rotate!
                rescue Exception => e
                    log "Exception: " << e.to_s
                end
            end
            
            # Removes orhpans
            log "Start of orphans removing."
            Storage::remove_orphans!
            
            # Saves state file
            State::save!
            log "New state saved."
        end
        
    end    
    
end
