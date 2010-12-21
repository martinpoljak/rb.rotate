# encoding: utf-8

require "rb.rotate/storage/item"
require "rb.rotate/mail"

module rbRotate
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
                
                return self.file.path
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
            # Mail file to specified address.
            #
            
            def mail!(to)
                if to.nil?
                    to = @storage.directory.configuration[:mail]
                end
                if to.nil?
                    raise Exception("No e-mail address specified for sending log to.")
                end
                
                require "etc"
                require "socket"

                Mail::send(
                    :from => Etc.getlogin.dup << "@" << Socket.gethostname,
                    :to => to,
                    :subject => Socket.gethostname.dup << " : log : " << self.file.path,
                    :body => ::File.read(self.file.path)
                )
                
                return self.file.path
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
