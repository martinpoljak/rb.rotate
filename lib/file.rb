# encoding: utf-8

require "fileutils"
require "lib/storage"

module RotateAlternative

    ##
    # Represents one log file.
    #
    
    class File
    
        ##
        # Holds parent file directory.
        #
        
        @directory
        attr_reader :directory
        
        ##
        # Indicates file path.
        #
        
        @path
        attr_reader :path
        
        ##
        # Holds state for the file.
        #
        
        @state
        
        ##
        # Constructor.
        #
        
        def initialize(directory, path)
            @directory = directory
            @path = path
        end
        
        ##
        # Removes the file from medium.
        #
        
        def remove!
            FileUtils.remove_file(@path)
        end
        
        ##
        # Creates new file.
        #
        
        def create!
            ::File.open(@path, "w")
        end
        
        ##
        # Truncates file.
        #
        
        alias :"truncate!" :"create!"
        
        ##
        # Rotates the file.
        #
        
        def rotate!
            if self.archivable?
                self.archive!
            end
        end
        
        ##
        # Archives file.
        #
        
        def archive!
            Storage::put(self)
        end
        
        ##
        # Indicates, file is suitable for immediate archiving.
        #
        
        def archivable?
            self.too_big? or self.too_old?
        end
        
        ##
        # Indicates, file is bigger than is allowed.
        #
        
        def too_big?
            ::File.size(@path) > @directory.configuration[:"max size"].to_bytes 
        end
        
        ##
        # Indicates, file is too old.
        #
        
        def too_old?
            if self.state.exists?
                period = @directory.configuration[:period].to_seconds
                multiplier =  @directory.configuration[:rotate]
                result = Time::at(self.state.date + (period * multiplier)) < Time::now
            else
                result = false
            end
            
            return result
        end
        
        ##
        # Returns state.
        #
        
        def state
            if @state.nil?
                @state = State::get.file(@path)
            end
            
            return @state
        end
        
    end
    
end
