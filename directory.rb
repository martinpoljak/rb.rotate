# encoding: utf-8

require "configuration"
require "file"
require "reader"

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
                # If no identifier set, looks for the dir 
                #  in configuration.
                if @identifier.nil?
                    directory = Configuration::find_path(@path)
                    
                    if not directory.nil?
                        @identifier = directory.identifier
                    else
                        @identifier = :default
                    end
                end
                
                @configuration = DirectoryConfiguration::new(@identifier)
            end
            
            return @configuration
        end
        
        ##
        # Returns path to directory.
        #
        # So it get @path or directory from configuration if hasn't 
        # been sete.
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
        
        def each_file(&block)
            Reader::read(self, :filter => :files, &block)
        end

        ##
        # Traverses through all directories in directory.
        #
        
        def each_directory(&block)
            Reader::new(self.path, :filter => :dirs, &block)
        end
        
        ##
        # Rotates.
        #
        
        def rotate!
            self.each_directory do |directory|
                directory.rotate!
            end
            self.each_file do |file|
                file.rotate!
            end
        end        
        
    end
    
end
