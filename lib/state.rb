# encoding: utf-8
require "yaml"

module RotateAlternative

    ##
    # Represents state file.
    #
    
    class State
    
        ##
        # Holds self-instance as singleton.
        #
        
        @@self = nil
        
        ##
        # Holds state data.
        #
        
        @data
        
        ##
        # Holds path to state file.
        #
        
        @path
        
        ##
        # Holds archive accessor instance.
        #
        
        @archive
        
        ##
        # Constructor.
        #
        
        def initialize
            @path = self.configuration.paths[:"state file"]
        end
        
        ##
        # Returns self instance.
        #
        
        def self.get
            if @@self.nil?
                @@self = self::new
            end
            
            return @@self
        end
        
        ##
        # Saves the file. (Shortcut to instance.)
        #
        
        def self.save!
            self::get.save!
        end
        
        ##
        # Alias for #archive.
        #
        
        def self.archive
            self::get.archive
        end
        
        ##
        # Alias for #files.
        #
        
        def self.files
            self::get.files
        end
        
        ##
        # Alias for #each_file.
        #
        
        def self.each_file(&block)
            self::get.each_file(&block)
        end
        
        ##
        # Returns data array.
        #
        
        def data
            if @data.nil?
                if not ::File.exists? @path
                    self.create!
                else
                    @data = YAML.load(::File.read(@path))
                end
            end
            
            return @data
        end
        
        ##
        # Formats new storage.
        #
        
        def new
            Hash[
                :archive => {
                    :files => { },
                    :directories => { }
                },
                
                :files => { },
            ]
        end
        
        ##
        # Creates new storage.
        #
        
        def create!
            @data = self.new
            self.save! 
        end
        
        ##
        # Saves the file.
        #
        
        def save!
            ::File.open(@path, "w") do |io|
                io.write(@data.to_yaml)
            end
        end
        
        ##
        # Returns archive accessor instance.
        #
        
        def archive
            if @archive.nil?
                @archive = StateModule::Archive::new(self.data[:archive])
            end
            
            return @archive
        end
        
        ##
        # Returns files list.
        #
        
        def files
            @data[:files]
        end
        
        ##
        # Returns record for appropriate file.
        #
        
        def file(path)
            data = self.files[path.to_sym]
            
            if data.nil?
                data = { }
                self.files[path.to_sym] = data
            end
            
            StateModule::File::new(data)
        end
        
        ##
        # Returns configuration object instance.
        #
        
        def configuration
            Configuration::get
        end
        
        ##
        # Traverses through all files and emits path and 
        # StateModule::File objects.
        #
        
        def each_file
            self.files.each_pair do |path, data|
                yield path, StateModule::File::new(data)
            end
        end
        
    end
    
end

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
        
        ##
        # Represents file state record.
        #
        
        class File

            ##
            # Holds the file data.
            #
            
            @data
            
            ##
            # Constructor.
            #
            
            def initialize(data)
                @data = data
            end
            
            ##
            # Indicates tate record for file exists.
            #
            
            def exists?
                not @data.empty?
            end
            
            ##
            # Returns last archival date.
            #
            
            def date
                @data[:date]
            end
            
            ##
            # Returns extension.
            #
            
            def extension
                @data[:filename][:extension]
            end
            
            ##
            # Returns basename.
            #
            
            def name
                @data[:filename][:name]
            end
            
            ##
            # Returns items list.
            #
            
            def items
                @data[:items]
            end
            
            ##
            # Returns directory specification.
            #
            
            def directory
                @data[:directory].to_sym
            end
            
            ##
            # Sets items list.
            #
            
            def items=(value)
                @data[:items].replace(value)
            end
            
            ##
            # Creates the state record.
            #
            
            def create(file)
                extension = ::File.extname(file.path)[1..-1]
                if extension.nil?
                    extension = nil
                    cut = 0..-1
                else
                    cut = 0..-2
                end
                
                new = {
                    :date => Time::now,
                    :items => { },
                    :directory => file.directory.identifier
                    :filename => {
                        :name => ::File.basename(file.path, extension.to_s)[cut],
                        :extension => extension
                    }
                }
                
                @data.replace(new)
            end
            
        end
        
    end
    
end
