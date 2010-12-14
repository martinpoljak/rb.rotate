# encoding: utf-8
require "yaml"

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
                @@self = self.class::new
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
        # Returns data array.
        #
        
        def data
            if @data.nil?
                if not File.exists? @path
                    self.create!
                else
                    @data = YAML.load(File.read(@path))
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
            File.open(@path, "w") do |io|
                io.write(@data.to_yaml)
            end
        end
        
        ##
        # Returns archive accessor instance.
        #
        
        def archive
            if @archive.nil?
                @archive = StateModule::Archive::new(@data[:archive])
            end
            
            return @archive
        end
        
        ##
        # Returns files list.
        #
        
        def files
            @data[:files]
        end
        
        ##
        # Returns configuration object instance.
        #
        
        def configuration
            Configuration::get
        end
        
    end
    
end

module RotateAlternative

    module StateModule
    
        ##
        # State file archive section.
        #
        
        class Archive
        
            ##
            # Holds the archive data.
            #
            
            @data
            
            ##
            # Constructor.
            #
            
            def initialize(data)
                @data = data
            end
            
            ##
            # Indicates, file is in archive.
            #
            
            def has_file?(path)
                @data[:files].has_key? path.to_sym
            end
            
            ##
            # Indicates, directory is in archive.
            #
            
            def has_directory?(path)
                @data[:directories].has_key? path.to_sym
            end
            
        end
        
    end
    
end
