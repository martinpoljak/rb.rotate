# encoding: utf-8

module RbRotate

    ##
    # Dispatches all operations.
    #
    
    class Dispatcher
        
        ##
        # Runs the rotate session.
        #
        
        def run!
            require "rb.rotate/configuration"
            require "rb.rotate/state"
            require "rb.rotate/storage"
            require "rb.rotate/log"

            # Reads configuration file
            locator = ::File.dirname(::File.dirname(__FILE__)).dup << "/paths.conf"
            if not ::File.exists? locator
                STDERR.write("FATAL: rb.rotate unconfigured. Please, run 'rb.rotate install' or eventually create the " << locator << " file with path to configuration file. Aborted.\n")
                exit
            end
            
            path = ::File.read(locator)
            path.strip!
            
            Configuration::read(path)
            log "Configuration file loaded."
            
            # Process
            log "Start of processing."
            Configuration::each_directory do |directory|
                begin
                    directory.rotate!
                rescue Exception => e
                    log "Exception: " << e.to_s
                end
            end
            
            # Removes orhpans
            log "Start of orphans removing."
            Storage::remove_orphans!
            
            # Saves state file
            State::save!
            log "New state saved."
        end
        
        ##
        # Installs the application configuration files.
        #
        
        def install!
            require "sys/uname"
            require "fileutils"
            
            basedir = ::File.dirname(__FILE__)
            
            # Loads and creates the configuration dir
            case Sys::Uname.sysname.downcase.to_sym
                when :freebsd
                    etc = "/usr/local/etc"
                when :linux
                    etc = "/etc"
                else
                    raise Exception::new("You are running on an unknown platform. It cannot be problem, but it's necessary define path to configuration file and define paths in configuration file.")
            end
            
            etc << "/rb.rotate"
            FileUtils.mkdir_p(etc)
            
            # Creates other important directories
            FileUtils.mkdir_p("/var/log")
            FileUtils.mkdir_p("/var/lib")
            
            # Puts configuration files to configuration directory
            source = basedir.dup << "/install"
            replacements = { "%%configuration" => etc }
            files = ["rotate.yaml", "defaults.yaml"]
            
            files.each do |file|
                body = ::File.read(source.dup << "/" << file << ".initial")
                replacements.each_pair do |key, value|
                    body.gsub! key, value
                end
                ::File.open(etc.dup << "/" << file, "w") do |io|
                    io.write(body)
                end
            end
            
            # Puts to library root path path to configuration directory
            ::File.open(basedir.dup << "/../paths.conf", "w") do |io|
                io.write(etc.dup << "/rotate.yaml")
            end
        end
        
        ##
        # Prints out system name.
        #
        
        def sysname!
            require "sys/uname"
            puts Sys::Uname.sysname.downcase
        end
        
    end    
    
end
