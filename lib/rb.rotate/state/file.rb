# encoding: utf-8
require "rb.rotate/state"

module rbRotate
    module StateModule
            
        ##
        # Represents file state record.
        #
        
        class File

            ##
            # Holds the file data.
            #
            
            @data
            
            ##
            # Holds path of the appropriate file.
            #
            
            @path
            
            ##
            # Constructor.
            #
            
            def initialize(path, data)
                @path = path
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
            # Touches date to current date.
            #
            
            def touch!
                @data[:date] = Time::now
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
                if @data.has_key? :directory 
                    @data[:directory].to_sym
                else
                    nil
                end
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
                    :directory => file.directory.identifier,
                    :filename => {
                        :name => ::File.basename(file.path, extension.to_s)[cut],
                        :extension => extension
                    }
                }
                
                @data.replace(new)
            end
            
            ##
            # Destroys the state record.
            #
            
            def destroy!
                State::files.delete(@path.to_sym)
                @data = nil
            end
            
        end
    end
end
