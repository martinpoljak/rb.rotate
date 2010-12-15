# encoding: utf-8

require "yaml"
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
        
        def self.get
            self::new
        end
        
        ##
        # Creates storage according to file and puts it to it.
        #
        
        def self.put(file)
            self.class::get(file.directory).put(file)
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
                    when :move, :copy
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
            
                # Rotates other items
                new_list = { }
                self.file.state.items.each_pair do |identifier, path|
                    identifier, path = Item::new(self, identifier, path).rotate!
                    new_list[identifier] = path
                end
                
                # Puts new item
                item = Item::new(self).allocate(method)
                
                self.file.state.items = new
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
            attr_reader :identifier
            
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
            
            def initialize(entry, identifier = 1, path = nil)
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
                state = @entry.file.state
                
                ##
                # Unregisters old filename, increases counter
                # and register it again.
                #
                
                self.unregister!
                @identifier += 1
                self.rebuild_path!
                self.register!
                
                return @identifier, @path
            end
            
            ##
            # Registers itself.
            #
            
            def register!
                archive.register_file(self.path, @date)
            end
            
            ##
            # Unregisters itself.
            #
            
            def unregister!
                archive.unregister_file(self.path)
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
                @path = @entry.storage.directory.path.dup << "/" << state.name << "." << @identifier.to_s << "." << state.extension
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
                    else
                        raise Exception::new("Invalid allocating method.")
                end
                
                if @entry.storage.compressed?
                    self.compress!
                end
                
                self.register!
            end
            
            ##
            # Compress the file if necessary.
            #
            
            def compress!
                system(@entry.storage.directory.configuration[:compress].dup << " " << self.path)
            end
            
        end
    end
end
