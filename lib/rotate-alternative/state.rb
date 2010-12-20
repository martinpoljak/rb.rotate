# encoding: utf-8

require "yaml"
require "rotate-alternative/configuration"
require "rotate-alternative/state/archive"
require "rotate-alternative/state/file"

module RotateAlternative

    ##
    # Represents state file.
    #
    
    class State
    
        ##
        # Holds self-instance as singleton.
        #
        
        @@self = nil
        
        ##
        # Holds state data.
        #
        
        @data
        
        ##
        # Holds path to state file.
        #
        
        @path
        
        ##
        # Holds archive accessor instance.
        #
        
        @archive
        
        ##
        # Constructor.
        #
        
        def initialize
            @path = self.configuration.paths[:"state file"]
        end
        
        ##
        # Returns self instance.
        #
        
        def self.get
            if @@self.nil?
                @@self = self::new
            end
            
            return @@self
        end
        
        ##
        # Saves the file. (Shortcut to instance.)
        #
        
        def self.save!
            self::get.save!
        end
        
        ##
        # Alias for #archive.
        #
        
        def self.archive
            self::get.archive
        end
        
        ##
        # Alias for #files.
        #
        
        def self.files
            self::get.files
        end
        
        ##
        # Alias for #each_file.
        #
        
        def self.each_file(&block)
            self::get.each_file(&block)
        end
        
        ##
        # Returns data array.
        #
        
        def data
            if @data.nil?
                if not ::File.exists? @path
                    self.create!
                else
                    @data = YAML.load(::File.read(@path))
                end
            end
            
            return @data
        end
        
        ##
        # Formats new storage.
        #
        
        def new
            Hash[
                :archive => {
                    :files => { },
                    :directories => { }
                },
                
                :files => { },
            ]
        end
        
        ##
        # Creates new storage.
        #
        
        def create!
            @data = self.new
            self.save! 
        end
        
        ##
        # Saves the file.
        #
        
        def save!
            self.compact!
            ::File.open(@path, "w") do |io|
                io.write(self.data.to_yaml)
            end
        end
        
        ##
        # Returns archive accessor instance.
        #
        
        def archive
            if @archive.nil?
                @archive = StateModule::Archive::new(self.data[:archive])
            end
            
            return @archive
        end
        
        ##
        # Returns files list.
        #
        
        def files
            self.data[:files]
        end
        
        ##
        # Compacts the file specifications.
        # It removes all empty entries records.
        #
        
        def compact!
            self.files.reject! do |key, value|
                value.empty?
            end
        end
        
        ##
        # Returns record for appropriate file.
        #
        
        def file(path)
            data = self.files[path.to_sym]
            
            if data.nil?
                data = { }
                self.files[path.to_sym] = data
            end
            
            StateModule::File::new(path, data)
        end
        
        ##
        # Returns configuration object instance.
        #
        
        def configuration
            Configuration::get
        end
        
        ##
        # Traverses through all files and emits path and 
        # StateModule::File objects.
        #
        
        def each_file
            self.files.each_pair do |path, data|
                if not data.empty?
                    yield path, StateModule::File::new(path, data)
                end
            end
        end
        
    end
end
