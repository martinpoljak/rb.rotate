# encoding: utf-8
require "rb.rotate/state"

module RbRotate

    ##
    # Represents reader of some directory.
    #
    
    class Reader
    
        ##
        # Directory for which reader has been created.
        #
        
        @directory
        
        ##
        # Reads the directory. (Shortcut for non-static read.)
        # Create new instance and call read.
        #
        
        def self.read(directory, options = { }, &block)
            self::new(directory).read(options, &block)
        end
        
        ##
        # Constructor.
        #
        
        def initialize(directory)
            @directory = directory
        end
        
        ##
        # Reads the directory content.
        #
        
        def read(options = { }, &block)
            filter = options[:filter]
        
            dirpath = @directory.path
            Dir.open(dirpath) do |dir|
                dir.each_entry do |item|
                    filepath = dirpath.dup << "/" << item
                    
                    if (not @directory.configuration[:follow]) and (::File.symlink? filepath)
                        next
                    elsif (filter.nil? or (filter == :files)) and (::File.file? filepath)
                        emit_file filepath, &block
                    elsif (filter.nil? or (filter == :dirs)) and (item != ?.) and (item.to_sym != :"..") and (::File.directory? filepath)
                        emit_directory filepath, &block
                    end
                end
            end
        end
        
        ##
        # Returns the state file object.
        #
        
        def state
            State::get
        end
        
        
        
        private
        
        ##
        # Emits file.
        #
        
        def emit_file(filepath)
            if not self.state.archive.has_file? filepath
                yield File::new(filepath, @directory)
            end
        end
        
        ##
        # Emits directory.
        #
        
        def emit_directory(filepath)
            if not self.state.archive.has_directory? filepath
                yield Directory::new(filepath, @directory)
            end
        end
        
    end
    
end


