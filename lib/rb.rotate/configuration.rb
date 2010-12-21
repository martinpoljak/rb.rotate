# encoding: utf-8

require "yaml"
require "rb.rotate/directory"

module RbRotate

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
        # Alias for #find_path.
        #
        
        def self.find_path(path)
            self::get.find_path(path)
        end
        
        ##
        # Opens the file.
        # 
        
        def read(file)
            data = YAML.load(::File.read(file))
            @data = { }
            
            # Converts strings to symbols
            data.each_pair do |name, section|
                section_data = { }
                @data[name.to_sym]= section_data
                
                if section.kind_of? Hash
                    section.each_pair do |key, value|
                        section_data[key.to_sym] = value
                    end
                end
            end
            
            defaults = YAML.load(::File.read(@data[:paths][:"defaults file"]))
            
            # Merges with defaults
            defaults.each_pair do |name, section|
                name = name.to_sym
                if not @data.has_key? name
                    @data[name] = value
                elsif section.kind_of? Hash
                    section.each_pair do |key, value|
                        key = key.to_sym
                        if not @data[name].has_key? key
                            @data[name][key] = value
                        end
                    end
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
            @data[:dirs].each_pair do |name, dir|
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

# String extensions

class String

    TO_TIME_MATCHER = /(\d+)\s*((?:year|month|week|day|hour|minute|second))s?/i

    ##
    # Converts number with units to bytes count.
    #
    
    def to_bytes
        value = self.to_i
        if value == 0
            raise Exception::new("Invalid size specification: " << self << ".")
        end
        
        exponent = nil
        case self[-1]
            when ?M
                exponent = 2
            when ?G
                exponent = 3
            when ?K
                exponent = 1
            when ?0, ?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9
                exponent = 0
            else
                raise Exception::new("Invalid unit in size specification: " << self << ".")
        end
        
        return value * (1024 ** exponent)
    end
    
    ##
    # Converts string identifier of time period to seconds.
    #
    
    def to_seconds
    
        period = nil
        case self.to_sym
            when :yearly
                period = "1 year"
            when :monthly
                period = "1 month"
            when :weekly
                period = "1 week"
            when :daily
                period = "1 day"
            when :hourly
                period = "1 hour"
            else
                period = self
        end
        
        matches = period.match(self.class::TO_TIME_MATCHER)
        if matches.nil?
            raise Exception::new("Invalid period specification: " << self << ".")
        end
        
        count = matches[1].to_i
        unit = matches[2].to_sym
        seconds = nil
        
        case unit
            when :year
                seconds = 365 * 24 * 60 * 60
            when :month
                seconds = 30 * 24 * 60 * 60
            when :week
                seconds = 7 * 24 * 60 * 60
            when :day
                seconds = 24 * 60 * 60
            when :hour
                seconds = 60 * 60
            when :second
                seconds = 1
        end
        
        return seconds * count
    end
        
end
