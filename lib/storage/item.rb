# encoding: utf-8

require "fileutils"
require "lib/state"

module RotateAlternative
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
            end
            
            ##
            # Returns data.
            #
            
            def data
                if not path.nil?
                    @data = State::get.archive.file(@path)
                end
                
                # Default
                if path.nil? or @data.nil?
                    compression = @entry.storage.directory.configuration[:compress]
                    if compression === true
                        compression = ["gzip --best", "gz"]
                    end
                    
                    @data = {
                        :date => Time::now,
                        :compression => compression
                    }
                end
                
                return @data
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
                State::archive.register_file(self.path, self.data)
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
                extension = self.compression[1]
                self.path[0...-(extension.length + 1)]
            end
            
            ##
            # Rebuilds path.
            #
            
            def rebuild_path!
                @path = @entry.storage.directory.configuration[:storage].dup << "/" << self.state.name.to_s << "." << self.identifier.to_s
                
                if not self.state.extension.nil?
                    @path << "." << self.state.extension
                end
                
                if self.compression
                    @path << "." << self.compression[1]
                end
            end
            
            ##
            # Allocates new record.
            #

            def allocate(method)
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
                result = self.data[:compression]
                if result.kind_of? Array
                    result = true
                end
                
                return result
            end
            
            ##
            # Compress the file.
            #
            
            def compress!
                if self.compressed?
                    command = self.compression[0]
                    FileUtils.move(self.path, self.target_path)
                    system(command.dup << " " << self.target_path)
                end
            end
            
            ##
            # Decompress file.
            #
            
            def decompress!
                if self.compressed? and self.exists?
                    command = self.compression[0]
                    system(command.dup << " " << self.path << " 2> /dev/null")
                    FileUtils.move(self.target_path, self.path)
                end
            end
            
            ##
            # Describes compression.
            #
            
            def compression
                self.data[:compression]
            end
            
            ##
            # Returns the creation date.
            #
            
            def created_at
                self.data[:date]
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
                self.expiration_at < Time::now
            end
            
        end
    end
end
