# encoding: utf-8

require "lib/configuration"
require "lib/file"
require "lib/reader"
require "lib/storage"

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
        # Parent configuration object.
        #
        
        @parent
        
        ##
        # Holds directory identifier.
        #
        
        @identifier
        attr_reader :identifier
        
        ##
        # Holds directory path.
        #
        
        @path
        attr_reader :path
        
        ##
        # Constructor.
        # 
        # Identifier is symbol so identifier in configuration file or
        # string, so directory path.
        #
        
        def initialize(identifier, parent = nil)
            @parent = parent
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
                    elsif not @parent.nil?
                        @identifier = @parent.identifier
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
            Reader::read(self, :filter => :dirs, &block)
        end
        
        ##
        # Rotates.
        #
        
        def rotate!
            # Cleans old or expired items
            # self.storage.cleanup! (cleaned up globally by dispatcher call)
            
            # Rotates
            if self.configuration[:recursive]
                self.each_directory do |directory|
                    directory.rotate!
                end
            end
            self.each_file do |file|
                file.rotate!
            end
        end        
        
        ##
        # Indicates, directory entries should be compressed 
        # in archive.
        #
        
        def compressable?
            not self.configuration[:compress].nil?
        end
        
        ##
        # Returns storage appropriate to directory.
        #
        
        def storage
            Storage::get(self)
        end
        
    end
    
end
