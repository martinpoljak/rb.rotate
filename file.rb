# encoding: utf-8
require "storage"

module RotateAlternative

    ##
    # Represents one log file.
    #
    
    class File
    
        ##
        # Holds parent file directory.
        #
        
        @directory
        
        ##
        # Indicates file path.
        #
        
        @path
        
        ##
        # Constructor.
        #
        
        def new(directory, path)
            @directory = directory
            @path = path
        end
        
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
            Storage::get(@directory).put(self)
        end
        
        ##
        # Indicates, file is suitable for immediate archiving.
        #
        
        def archivable?
            return self.too_big? or self.too_old?
        end
        
        ##
        # Indicates, file is bigger than is allowed.
        #
        
        def too_big?
            (File.size? @path) > @directory.configuration[:"max size"].to_bytes 
        end
        
        ##
        # Indicates, file is too old.
        #
        
        def too_old?
            Time::at(self.state.files[@path.to_sym] + @directory.configuration[:"period"].to_seconds) < Time::now
        end
        
        ##
        # Returns state.
        #
        
        def state
            State::get
        end
        
    end
    
end
