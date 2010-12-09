# encoding: utf-8

require "yaml"
require "directory"

module RotateAlternative

    ##
    # Directory configuration.
    #
    
    class DirectoryConfiguration
    
        ##
        # Holds currently selected directory section.
        #
        
        @directory
    
        ##
        # Constructor.
        #
        # Expects file path and directory section specification 
        # as symbol.
        #
        
        def initialize(directory)
            @directory = directory
        end
        
        ##
        # Returns configuration file setting.
        #
        
        def configuration
            Configuration::get
        end
        
        ##
        # Returns some item.
        #
        
        def [](name)
            self.configuration[@directory][name]
        end
        
        ##
        # Handles method calls.
        #
        
        def method_missing(name)
            self[name]
        end
        
    end
    
    ##
    # General configuration file.
    #
    
    class Configuration
    
        ##
        # Brings self instance. (Class is singletone.)
        #
        
        @@self = nil
        
        ##
        # Holds data.
        #
        
        @data
        
        ##
        # Opens the file. (Shortcut for instance call.)
        #
        
        def self.read(file)
            self::get.read(file)
        end
        
        ##
        # Returns the single instance.
        #
        
        def self.get
            if @@self.nil?
                @@self = self::new
            end
            
            return @@self
        end
        
        ##
        # Opens the file.
        # 
        
        def read(file)
            data = YAML.load(File.read(file))
            @data = { }
            
            # Converts strings to symbols
            data.each_pair do |name, dir|
                dir_data = { }
                @data[name.to_sym]= dir_data
                
                dir.each_pair do |key, value|
                    dir_data[key.to_sym] = value
                end
            end
        end
        
        ##
        # Returns an item.
        #
        
        def [](name)
            @data[name]
        end
        
        ##
        # Handles method calls.
        #
        
        def method_missing(name)
            self[name]
        end
        
        ##
        # Traverses through each directory configuration.
        #
        
        def each_directory
            @data.each_pair do |name, dir|
                yield Directory::new(name, dir)
            end
        end
        
    end
    
end
