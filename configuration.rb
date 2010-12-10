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
        # Holds configuration data.
        #
        
        @data
    
        ##
        # Constructor.
        #
        # Expects file path and directory section specification 
        # as symbol.
        #
        
        def initialize(directory)
            # TODO: this should handle configuration inheritance
            @directory = directory
        end
        
        ##
        # Returns configuration file setting.
        #
        
        def configuration
            Configuration::get
        end
        
        ##
        # Returns configuration data.
        #

        def data
            if @data.nil?
                data = self.configuration[:dirs][@directory]
                @data = { }
                
                # Converts strings to symbols
                data.each_pair do |key, value|
                    @data[key.to_sym] = value
                end
                
                self.handle_inheritance!
            end
            
            return @data
        end
        
        ##
        # Handles configuration inheritance.
        #

        def handle_ihneritance!
            if @data.include? :parent
                @data.merge! self.class::new(@data[:parent]).data
            end
        end
        
        ##
        # Returns some item.
        #
        
        def [](name)
            self.data[name]
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
        # Traverses through each directory configuration. 
        # (Shortcut for instace call.)
        
        def self.each_directory(&block)
            self::get.each_directory(&block)
        end
        
        ##
        # Opens the file.
        # 
        
        def read(file)
            data = YAML.load(File.read(file))
            @data = { }
            
            # Converts strings to symbols
            data.each_pair do |name, section|
                section_data = { }
                @data[name.to_sym]= section_data
                
                section.each_pair do |key, value|
                    section_data[key.to_sym] = value
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
        
        ##
        # Looks for directory in configuration.
        #
        
        def find_path(path)
            @data.each_pair do |name, dir|
                if dir[:directory] == path
                    return Directory::new(name, dir)
                end
            end
            
            return nil
        end
        
    end
    
end
