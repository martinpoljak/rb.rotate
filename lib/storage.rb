# encoding: utf-8

require "fileutils"
require "lib/state"

module RotateAlternative

    ##
    # Represents storage for archived files.
    #
    
    class Storage

        ##
        # Directory for which storage is aimed.
        #
        
        @directory
        attr_reader :directory
    
        ##
        # Constructor.
        #
        
        def initialize(directory)
            @directory = directory
        end
        
        ##
        # Alias for new.
        #
        
        def self.get(directory)
            self::new(directory)
        end
        
        ##
        # Creates storage according to file and puts it to it.
        #
        
        def self.put(file)
            self::get(file.directory).put(file)
        end
        
        ##
        # Puts file to storage.
        #
        
        def put(file)
            self.do_actions! file
        end
        
        ##
        # Indicates, storage is compressed.
        #
        
        def compressed?
            self.directory.compressable?
        end
        
        ##
        # Runs file actions.
        #
        
        def do_actions!(file)
        
            # Loads them
            actions = @directory.configuration[:action].split("+")
            actions.each { |i| i.strip! }
            actions.map! { |i| i.to_sym }
            
            # Does them
            actions.each do |action|
                case action
                    when :move, :copy, :append
                        StorageModule::Entry::new(self, file).put! action
                    when :remove
                        file.remove!
                    when :create
                        file.create!
                    when :truncate
                        file.truncate!
                    else
                        # TODO: hooks
                end
            end
        end
        
        ##
        # Cleanups expired items from the storage.
        #
        
        def cleanup!
            self.each_entry do |entry|
                entry.cleanup!
            end
        end
        
        ##
        # Returns item identifier of the storage.
        #
        
        def item_identifier
            self.directory.configuration[:identifier]
        end
        
        ##
        # Indicates numeric identifier.
        #
        
        def numeric_identifier?
            self.item_identifier.to_sym == :numeric
        end
        
        ##
        # Removes orphans.
        #
        
        def self.remove_orphans!
            self::each_entry do |entry|
                items_count = 0
                
                entry.each_item do |item|
                    if item.expired?
                        item.remove!
                    elsif not item.exists?
                        item.unregister!
                    else
                        items_count += 1
                    end
                end
                
                file = entry.file
                if (not file.exists?) and (items_count <= 0)
                    file.state.destroy!
                end                    
            end
        end
                
        ##
        # Traverses through each item in current storage.
        #
        
        def each_item(&block)
            self.each_entry do |entry|
                entry.each_item(&block)
            end
        end
                
        ##
        # Traverses through all entries of this directory storage.
        #
        
        def each_entry
            State::each_file do |path, state|
                if state.directory == self.directory.identifier
                    file = File::new(path)
                    entry = StorageModule::Entry::new(self, file)
                    
                    yield entry
                end
            end
        end
        
        ##
        # Traverses through all items in global storage.
        #
        
        def self.each_item(&block)
            self.each_entry do |entry|
                entry.each_item(&block)
            end
        end
        
        ##
        # Traverses through all entries.
        #
        
        def self.each_entry
            State::each_file do |path, state|
                file = File::new(path)
                storage = self::new(file.directory)
                entry = StorageModule::Entry::new(storage, file)
                
                yield entry
            end
        end
        
        ##
        # Traverses through all directories in storage.
        #
        
        def self.each_directory
            Configuration::each_directory do |directory|
                yield self::get(directory)
            end
        end
        
    end
    
    
    module StorageModule
    
        ##
        # Represents an entry of the storage.
        # Entry is archived items of one file.
        #
        
        class Entry
            
            ##
            # Holds file of the entry.
            #
            
            @file
            attr_reader :file
            
            ##
            # Holds parent storage.
            #
            
            @storage
            attr_reader :storage
            
            ##
            # Constructor.
            #
            
            def initialize(storage, file)
                @storage = storage
                @file = file
            end
            
            ##
            # Puts current version of the file to items.
            #
            
            def put!(method)
            
                # If necessary, creates the state record
                if not self.file.state.exists?
                    self.file.state.create(@file)
                end
            
                # Rotates other items
                new_list = { }
                self.each_item do |item|
                    if item.exists?
                        item.rotate!
                        new_list[item.identifier] = item.path
                    else
                        item.unregister!
                    end
                end
                
                # Puts new item
                item = Item::new(self).allocate(method)
                new_list[item.identifier] = item.path
                
                self.file.state.touch!
                self.file.state.items = new_list
            end
            
            ##
            # Cleanups the items.
            #
            
            def cleanup!
                self.each_item do |item|
                    if item.expired?
                        item.remove!
                    end
                end
            end
            
            ##
            # Traverses through all items.
            #
            
            def each_item
                self.file.state.items.each_pair do |identifier, path|
                    yield Item::new(self, identifier, path)
                end
            end
            
        end
        
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
                        ::File.open(self.path, "a") do |io|
                            io.write(::File.read(@entry.file.path))
                        end
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
            # Compress the file if necessary.
            #
            
            def compress!
                system(@entry.storage.directory.configuration[:compress].dup << " " << self.path)
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
