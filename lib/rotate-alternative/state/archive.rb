# encoding: utf-8

module RotateAlternative
    module StateModule
    
        ##
        # State file archive section.
        #
        
        class Archive
        
            ##
            # Holds the archive data.
            #
            
            @data
            
            ##
            # Constructor.
            #
            
            def initialize(data)
                @data = data
            end
            
            ##
            # Returns file data.
            #
            
            def file(path)
                self.files[path.to_sym]
            end
            
            ##
            # Returns files data.
            #
            
            def files
                @data[:files]
            end
            
            ##
            # Indicates, file is in archive.
            #
            
            def has_file?(path)
                @data[:files].has_key? path.to_sym
            end
            
            ##
            # Indicates, directory is in archive.
            #
            
            def has_directory?(path)
                @data[:directories].has_key? path.to_sym
            end
            
            ##
            # Registers file.
            #
            
            def register_file(path, value = true)
                self.register_item(:files, path, value)
            end
            
            ##
            # Unregisters file.
            #
            
            def unregister_file(path)
                self.unregister_item(:files, path)
            end
            

            ##
            # Registers directory.
            #
            
            def register_directory(path, value = true)
                self.register_item(:directories, path, value)
            end
            
            ##
            # Unregisters file.
            #
            
            def unregister_directory(path)
                self.unregister_item(:directories, path)
            end
            
            ##
            # Registers item.
            #
            
            def register_item(group, path, value = true)
                @data[group][path.to_sym] = value
            end
            
            ##
            # Unregister item.
            #
            
            def unregister_item(group, path)
                @data[group].delete(path.to_sym)
            end
            
        end
    end
end
