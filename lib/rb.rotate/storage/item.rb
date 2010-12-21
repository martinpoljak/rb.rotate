# encoding: utf-8

require "fileutils"
require "rb.rotate/state"
require "rb.rotate/mail"

module RbRotate
    module StorageModule
        
        ##
        # Represents an item of some entry in storage.
        #
        
        class Item
            
            ##
            # Parent entry.
            #

            @entry
            
            ##
            # Indentifier of the item.
            #
            
            @identifier
            attr_writer :identifier
            
            ##
            # Full path of the item.
            #
            
            @path
            
            ##
            # Data of the item.
            #
            
            @data
            
            ##
            # Constructor.
            #
            
            def initialize(entry, identifier = nil, path = nil)
                @entry = entry
                @identifier = identifier
                @path = path

                # Loads data
                self.load_data!
            end
            
            ##
            # Returns data.
            #
            
            def load_data!
                if @data.nil?
                    if not @path.nil?
                        @data = State::get.archive.file(@path)
                    end
                    
                    # Default
                    if @path.nil? or @data.nil?
                        @data = {
                            :date => Time::now,
                            :compression => false
                        }
                    end
                end
            end
            
            ##
            # Rotates itself.
            #

            def rotate!
                if @entry.storage.numeric_identifier? and (self.identifier.kind_of? Numeric)
                    ##
                    # Unregisters old filename, increases counter
                    # and register it again.
                    #
                    
                    self.unregister!
                    
                    if self.exists?
                        old_path = self.path
                        self.identifier += 1
                        
                        self.rebuild_path!
                        self.prepare_directory!
                        FileUtils.move(old_path, self.path)

                        self.register!
                    end
                end
                    
                return self
            end
            
            ##
            # Returns state object.
            #
            
            def state
                @entry.file.state
            end
            
            ##
            # Indicates, item still exists in storage.
            #
            
            def exists?
                ::File.exists? self.path
            end
            
            ##
            # Registers itself.
            #
            
            def register!
                State::archive.register_file(self.path, @data)
            end
            
            ##
            # Unregisters itself.
            #
            
            def unregister!
                State::archive.unregister_file(self.path)
            end
            
            ##
            # Removes itself.
            #
            
            def remove!
                self.unregister!
                
                # Eventually mails it if required
                if @entry.storage.directory.configuration[:recycle].to_sym == :mail
                    self.mail!
                end
                
                FileUtils.remove(self.path)
            end
            
            ##
            # Mails the file.
            #
            
            def mail!
                to = @entry.storage.directory.configuration[:mail]
                self.decompress!
                
                require "etc"
                require "socket"
                
                Mail::send(
                    :from => Etc.getlogin.dup << "@" << Socket.gethostname,
                    :to => to,
                    :subject => Socket.gethostname << " : log : " << self.path,
                    :body => ::File.read(self.target_path)
                )
                
                self.compress!
            end
            
            ##
            # Returns identifier.
            #
            
            def identifier
                if @identifier.nil?
                    if @entry.storage.numeric_identifier?
                        @identifier = 1
                    else
                        item_identifier = @entry.storage.item_identifier
                        
                        if item_identifier.to_sym == :date
                            format = "%Y%m%d.%H%M"
                        else
                            format = item_identifier
                        end
                        
                        @identifier = Time::now.strftime(format)
                    end
                end
                
                return @identifier
            end
            
            ##
            # Returns path.
            #
            
            def path
                if @path.nil?
                    self.rebuild_path!
                end
                
                return @path
            end
            
            ##
            # Generates target (without compression extension) path 
            # from path.
            #
            
            def target_path
                if self.compressed?
                    extension = self.compression[:extension]
                    result = self.path[0...-(extension.length + 1)]
                else
                    result = self.path
                end
                
                return result
            end
            
            ##
            # Rebuilds path.
            #
            
            def rebuild_path!
                directory = @entry.storage.directory
                configuration = directory.configuration
                @path = configuration[:storage].dup << "/"
                
                # Adds archive subdirectories structure if necessary
                recursive = configuration[:recursive]
                if (recursive.kind_of? TrueClass) or (configuration[:recursive].to_sym != :flat)
                    relative_path = directory.relative_path
                    if relative_path != ?.
                        @path << relative_path << "/"
                    end
                end
                
                # Adds filename
                @path << self.state.name.to_s << "." << self.identifier.to_s
                
                # Adds extension if necessary
                if not self.state.extension.nil?
                    @path << "." << self.state.extension
                end
                                
                # Adds compression extension if necessary
                if self.compressed?
                    @path << "." << self.compression[:extension]
                end
            end
            
            ##
            # Prepares directory.
            #
            
            def prepare_directory!
                directory = FileUtils.mkdir_p(::File.dirname(self.path)).first
                State::archive.register_directory(directory)
            end
            
            ##
            # Allocates new record.
            #

            def allocate(method)
            
                # Prepares directory
                self.prepare_directory!
                
                # Allocates by required action
                case method
                    when :copy
                        FileUtils.copy(@entry.file.path, self.path)
                    when :move
                        FileUtils.move(@entry.file.path, self.path)
                    when :append
                        self.append!(:"no compress")
                    else
                        raise Exception::new("Invalid allocating method.")
                end
                
                self.compress!                
                self.register!
                
                return self
            end
            
            ##
            # Appends to item.
            #
            
            def append!(compress = :compress)
                self.decompress!
                
                ::File.open(self.path, "a") do |io|
                    io.write(::File.read(@entry.file.path))
                end                
                
                if compress == :compress
                    self.compress!
                end
            end
            
            ##
            # Indicates file is or file should be compressed.
            #
            
            def compressed?
                result = @data[:compression]
                if result.kind_of? Array
                    result = true
                end
                
                return result
            end
            
            ##
            # Compress the file.
            #
            
            def compress!
            
                # Checking out configuration
                configuration = @entry.storage.directory.configuration
                command, extension = configuration[:compress]
                decompress = configuration[:decompress]

                if not command.kind_of? FalseClass
                
                    # Setting file settings according to current 
                    # configuration parameters
                    
                    if command.kind_of? TrueClass
                        command = "gzip --best"
                        extension = "gz"
                    end
                    if decompress.kind_of? TrueClass
                        decompress = "gunzip"
                    end
               
                    @data[:compression] = {
                        :decompress => decompress,
                        :extension => extension
                    }
                    
                    # Compress
                    system(command.dup << " " << self.path)
                    self.rebuild_path!
                end
            end
            
            ##
            # Decompress file.
            #
            
            def decompress!
                if self.compressed? and self.exists?
                    command = self.compression[:decompress]
                    system(command.dup << " " << self.path << " 2> /dev/null")
                    FileUtils.move(self.target_path, self.path)
                end
            end
            
            ##
            # Describes compression.
            #
            
            def compression
                @data[:compression]
            end
            
            ##
            # Returns the creation date.
            #
            
            def created_at
                @data[:date]
            end
            
            ##
            # Returns the expiration date.
            #
            
            def expiration_at
                configuration = @entry.storage.directory.configuration
                period = configuration[:period].to_seconds
                multiplier = configuration[:rotate]
                
                return self.created_at + (period * multiplier)
            end
            
            ##
            # Indicates, item is expired.
            #
            
            def expired?
                recycle = @entry.storage.directory.configuration[:recycle]
                if recycle.kind_of? FalseClass
                    result = false
                else
                    recycle = recycle.to_sym
                end
                
                if recycle and (recycle == :remove) or (recycle == :mail)
                    result = self.expiration_at < Time::now
                end
                
                return result
            end
            
        end
    end
end
