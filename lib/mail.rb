# encoding: utf-8

module RotateAlternative

    ##
    # Dispatches all operations.
    #
    
    class Mail 
    
        ##
        # Pony class for delivering.
        #
        
        @@pony = nil
        
        ##
        # Sends mail through Pony mail using specified parameters.
        #
        
        def self.send(parameters)
            self::pony.mail(parameters)
        end
        
        ##
        # Returns the Pony class (includes if necessary).
        #
        
        def self.pony
            if @@pony.nil?
                require "pony"
                @@pony = Pony
            end
            
            return @@pony
        end
        
    end    
    
end
