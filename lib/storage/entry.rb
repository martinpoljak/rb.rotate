# encoding: utf-8

require "lib/storage/item"

module RotateAlternative
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
    end
end
