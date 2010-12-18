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
            # Date of the item.
            #
            
            @date
            
            ##
            # Constructor.
            #
            
            def initialize(entry, identifier = nil, path = nil)
                @entry = entry
                @identifier = identifier
                
                if not path.nil?
                    @path = path
                    @date = State::get.archive.file(@path)
                else
                    @date = Time::now
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
                        FileUtils.move(old_path, self.path)

                        self.register!
                    end
                end
                    
                return self
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
                State::archive.register_file(self.path, @date)
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
                FileUtils.remove(self.path)
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
            # Rebuilds path.
            #
            
            def rebuild_path!
                state = @entry.file.state
                @path = @entry.storage.directory.configuration[:storage].dup << "/" << state.name << "." << self.identifier.to_s
                
                if not state.extension.nil?
                    @path << "." << state.extension
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
                        self.append!
                    else
                        raise Exception::new("Invalid allocating method.")
                end
                
                if @entry.storage.compressed?
                    self.compress!
                end
                
                self.register!
                return self
            end
            
            ##
            # Appends to item.
            #
            
            def append!
                if @entry.file.state.compressed?
                    self.decompress!
                end
                
                ::File.open(self.path, "a") do |io|
                    io.write(::File.read(@entry.file.path))
                end                
            end
            
            ##
            # Compress the file.
            #
            
            def compress!
                command = @entry.storage.directory.configuration[:compress]
                if command === true
                    command = "gzip --best"
                else
                    command = command.dup
                end
                
                system(command << " " << self.path)
            end
            
            ##
            # Decompress file.
            #
            
            def decompress!
                command = @entry.storage.directory.configuration[:decompress]
                if command === true
                    command = "gunzip"
                else
                    command = command.dup
                end
               
                system(command << " " << self.path << " 2> /dev/null")
            end
            
            ##
            # Returns the creation date.
            #
            
            def created_at
                @date
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
