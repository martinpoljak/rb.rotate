# encoding: utf-8
require "rb.rotate/configuration"

module RbRotate

    ##
    # Logfile.
    #
    
    class Log 
    
        ##
        # Singletone instance.
        #
        
        @@self = nil
        
        ##
        # Path to log.
        #
        
        @path
        
        ##
        # Returns its singletone instance.
        #
        
        def self.get
            if @@self.nil?
                @@self = self::new(Configuration::get.paths[:"log file"])
            end
            
            return @@self
        end
        
        ##
        # Alias for #write.
        #
        
        def self.write(message, caller = nil)
            self::get.write(message, caller)
        end
        
        ##
        # Constructor.
        #
        
        def initialize(path)
            @path = path
        end
        
        ##
        # Writes to log.
        #
        
        def write(message, caller = nil)
            output = "[" << Time.now.strftime("%Y-%m-%d %H:%M:%S.%L") << "] "
            if caller
                output << caller.class.name << ": "
            end
            output << message << "\n"
            
            ::File.open(@path, "a") do |io|
                io.write(output)
            end
        end
    end    
    
end


class Object
    ##
    # Logs an message.
    #

    def log(message)
        RbRotate::Log::write(message, self)
    end    
end
