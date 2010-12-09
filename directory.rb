# encoding: utf-8

require "configuration"
require "file"

module RotateAlternative

    ##
    # Represents one log directory.
    #
    
    class Directory
        
        ##
        # Internal cache of the configuration.
        #
        
        @configuration
        
        ##
        # Holds directory identifier.
        #
        
        @identifier
        
        ##
        # Holds directory path.
        #
        
        @path
        
        ##
        # Constructor.
        # 
        # Identifier is symbol so identifier in configuration file or
        # string, so directory path.
        #
        
        def initialize(identifier)
            if identifier.kind_of? Symbol
                @identifier = identifier
            else
                @path = identifier
            end
        end
    
        ##
        # Returns the configuration instance.
        #
        
        def configuration
            if @configuration.nil?
                @configuration = DirectoryConfiguration::new(@identifier)
            end
            
            return @configuration
        end
        
        ##
        # Returns path to directory.
        #
        # So it get @path or directory from configuration if hasn't 
        # been set.
        #
        
        def path
            if not @path.nil?
                @path
            else
                self.configuration.directory
            end
        end
        
        ##
        # Traverses through all files in directory.
        #
        
        def each_file
            dirpath = self.path
            Dir.open(dirpath) do |dir|
                dir.each_entry do |item|
                    filepath = dirpath.dup << "/" item
                    if File.file? filepath
                        yield File::new(self, filepath)
                    end
                end
            end
        end

        ##
        # Traverses through all directories in directory.
        #
        
        def each_directory
            dirpath = self.path
            Dir.open(dirpath) do |dir|
                dir.each_entry do |item|
                    filepath = dirpath.dup << "/" item
                    if File.directory? filepath
                        yield self::new(filepath)
                    end
                end
            end
        end
        
        
    end
    
end
