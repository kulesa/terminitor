module Terminitor
  # This class parses the Termfile to fit the new Ruby Dsl Syntax
  class Dsl

    def initialize(path)
      file = File.read(path)
      @setup = []
      @windows = { 'default' => {}}
      @options = {}
      @_context = @windows['default'] 
      instance_eval(file)
    end

    # Contains all commands that will be run prior to the usual 'workflow'
    # e.g bundle install, setup forks, etc ...
    # setup "bundle install", "brew update"
    # setup { run('bundle install') }
    def setup(*commands, &block)
      setup_tasks = @setup
      if block_given?
        @_context, @_old_context = setup_tasks, @_context
        instance_eval(&block)
        @_context = @_old_context
      else
        setup_tasks.concat(commands)
      end
    end

    # sets command context to be run inside a specific window
    # window(:name => 'new window', :size => [80,30], :position => [9, 100]) { tab('ls','gitx') }
    # window { tab('ls', 'gitx') }
    def window(options = nil, &block)
      options ||= {}      
      window_name = options[:name] || "window#{@windows.keys.size}"
      @options[window_name] = options
      window_tabs = @windows[window_name] = {}
      @_context, @_old_context = window_tabs, @_context
      instance_eval(&block)
      @_context = @_old_context
    end

    # stores command in context
    # run 'brew update'
    def run(command)
      @_context << command
    end

    # sets command context to be run inside specific tab
    # tab(:name => 'new tab', :settings => 'Grass') { run 'mate .' }
    # tab 'ls', 'gitx'
    def tab(options = nil, *commands, &block)
      options ||= {}
      if block_given?
        tab_name = options[:name] || "tab#{@_context.keys.size}"
        @options[tab_name] = options
        tab_tasks = @_context[tab_name] = []
        @_context, @_old_context = tab_tasks, @_context
        instance_eval(&block)
        @_context = @_old_context
      else
        tab_tasks = @_context["tab#{@_context.keys.size}"] = []
        tab_tasks.concat([options] + commands)
      end
    end

    # Returns yaml file as Terminitor formmatted hash
    def to_hash
      { :setup => @setup, :windows => @windows, :options => @options }
    end


    private

    #
    # in_context @setup, commands, &block
    # in_context @tabs["name"], commands, &block
    def in_context(tasks_instance,*commands, &block)
      if block_given?
        @_context, @_old_context = instance_variable_get(name), @_context
        instance_eval(&block)
        @_context = @_old_context
      else
        @setup << commands
      end
    end


  end
end
