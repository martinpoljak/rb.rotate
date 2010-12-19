# encoding: utf-8
require "yaml"

module RotateAlternative

    ##
    # Represents hook.
    #
    
    class Hook
        
        ##
        # Holds name of the hook.
        #
        
        @name
        
        ##
        # Holds data of the hook.
        #
        
        @data
        
        ##
        # Holds arguments of the hook.
        #
        
        @arguments
        
        ##
        # Hold variables for the hook.
        #
        
        @variables
        
        ##
        # Constructor.
        #
        
        def initialize(name, arguments = nil, variables = { })
            @name = name
            @arguments = self.parse_arguments(arguments)
            @variables = variables
        end
        
        ##
        # Parses "arguments line".
        #
        
        def parse_arguments(string)
            if not string.nil?
                string.split(":")
            else
                []
            end
        end
        
        ##
        # Runs hook.
        #
        
        def run!
            # Gets commans
            command = self.command.dup
            
            # Adds arguments
            self.expand_arguments(command)
            
            # Adds variables
            self.expand_variables(command)
            
            # Runs it
            pipe = ::File.popen(command)
            pipe.eof?       # ask for EOF causes waiting for terminating the pipe process
            
            result = pipe.read
            pipe.close()

            # Parses and returns result
            return self.parse_result(result)
        end
        
        ##
        # Expands arguments.
        #
        
        def expand_arguments(command)
            @arguments.each_index do |i|
                arg = arguments[i]
                command.gsub! "%" << i.to_s, '"' << arg << '"'
            end            
        end
        
        ##
        # Expands variables.
        #
        
        def expand_variables(command)
            @variables.each_pair do |name, value|
                command.gsub! "%" << name, '"' << value << '"'
            end
        end
        
        ##
        # Parses result.
        #
        
        def parse_result(result)
            if result.strip.empty?
                return { }
            end
        
            result = YAML.load(result)
            if not result.kind_of? Hash
                result = { }
                STDERR.write("Warning: result of hook '" << @name.to_s << "' wasn't YAML collection. Ignored.")
            end
            
            return result
        end
        
        ##
        # Gets command.
        #
        
        def command
            command = Configuration::get.hooks[@name]
            if command.nil?
                raise Exception::new("Invalid hook: " << @name.to_s)
            end
        end
        
    end
    
end
