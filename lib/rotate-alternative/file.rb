# encoding: utf-8

require "fileutils"
require "rotate-alternative/storage"
require "rotate-alternative/directory"
require "rotate-alternative/configuration"

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
        attr_reader :path
        
        ##
        # Holds state for the file.
        #
        
        @state
        
        ##
        # Holds stat informations about the (original) file.
        #
        
        @stat
        
        ##
        # Constructor.
        #
        
        def initialize(path, directory = nil)
            @directory = directory
            @path = path
            @stat = ::File.stat(@path.to_s)
        end
        
        ##
        # Returns the file parent directory object.
        #
        
        def directory
            if @directory.nil?
                if not self.state.directory.nil?
                    @directory = Directory::new(self.state.directory)
                else
                    @directory = Configuration::find_path(::File.dirname(@path.to_s))
                end
                    
                if @directory.nil?
                    raise Exception::new("File from directory which isn't convered by rotate-alternative found: " << @path.to_s  << ".")
                end
            end
            
            return @directory
        end
        
        ##
        # Removes the file from medium.
        #
        
        def remove!
            FileUtils.remove_file(@path)
            return @path
        end
        
        ##
        # Creates new file.
        #
        
        def create!
            ::File.open(@path, "w").close()
            
            # Sets access rights and ownership according to 
            # stat information
            if not @stat.nil?
                ::FileUtils.chmod(@stat.mode, @path)
                ::FileUtils.chown(@stat.uid, @stat.gid, @path)
            end
            
            return @path
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
                result = Time::at(self.state.date + period) < Time::now
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
        
        ##
        # Indicates file exists.
        #
        
        def exists?
            ::File.exists? @path.to_s
        end
        
    end
    
end
