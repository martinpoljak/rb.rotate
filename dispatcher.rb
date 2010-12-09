# encoding: utf-8

module RotateAlternative

    ##
    # Dispatches all operations.
    #
    
    class Dispatcher
        
        ##
        # Internal cache of the global configuration.
        #
        
        @configuration
    
        ##
        # Runs the rotate session.
        #
        
        def run
            self.configuration.each_directory do |name, directory|
                directory.each_file do |file|
                    
                end
            end
        end

        ##
        # Returns the global configuration instance.
        #
        
        def configuration
            if @configuration.nil?
                @configuration = Configuration::new("./rotate.yaml")
            end
            
            return @configuration
        end
        
    end
    
end
