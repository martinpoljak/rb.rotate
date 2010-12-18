# encoding: utf-8

require "lib/storage/entry"
require "lib/file"
require "lib/configuration"

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
            entry = StorageModule::Entry::new(self, file)
        
            # Loads them
            actions = @directory.configuration[:action].split("+")
            actions.map! do |i| 
                i.strip!
                k, v = i.split(":", 2)
                [k.to_sym, v]
            end
            
            # Does them
            actions.each do |action, arguments|
                case action
                    when :move, :copy, :append
                        entry.put! action
                    when :remove
                        file.remove!
                    when :create
                        file.create!
                    when :truncate
                        file.truncate!
                    when :mail
                        entry.mail! arguments
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
end
