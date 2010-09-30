module Terminitor
  # Mac OS X Core for Terminitor
  # This Core manages all the interaction with Appscript and the Terminal
  class MacCore < AbstractCore
    include Appscript
    
    # Initialize @terminal with Terminal.app, Load the Windows, store the Termfile
    # Terminitor::MacCore.new('/path')
    def initialize(path)
      super
      @terminal = app('Terminal')
      @windows  = @terminal.windows
    end
            
    # executes the given command via appscript
    # execute_command 'cd /path/to', :in => #<tab>
    def execute_command(cmd, options = {})
      active_window.do_script(cmd, options)
    end

    # Opens a new tab and returns itself.
    def open_tab(options = nil)
      terminal_process.keystroke("t", :using => :command_down)
      set_options(return_last_tab, options) if options
      return_last_tab
    end
    
    # Opens A New Window, applies settings to the first tab and returns the tab object.
    def open_window(options = nil)
      terminal_process.keystroke("n", :using => :command_down)
      # ugly, but need to set first tab settings before window size, 
      # because change of the first tab options causes change of window size
      if options
        window_options  = Hash[ options.select {|option, value| MacCapture::OPTIONS_MASK[:window].include?(option) }]
        tab_options     = Hash[ options.select {|option, value| MacCapture::OPTIONS_MASK[:tab].include?(option) }]
        set_options(active_window, tab_options)
        set_options(active_window, window_options)      
      end
      return_last_tab
    end

    # Returns the Terminal Process
    # We need this method to workaround appscript so that we can instantiate new tabs and windows.
    # otherwise it would have looked something like window.make(:new => :tab) but that doesn't work.
    def terminal_process
      app("System Events").application_processes["Terminal.app"]
    end
    
    # Returns the last instantiated tab from active window
    def return_last_tab
      local_window = active_window
      local_tabs = local_window.tabs if local_window
      local_tabs.last.get if local_tabs
    end

    # returns the active window by checking if its the :frontmost 
    def active_window
      windows = @terminal.windows.get
      windows.detect do |window|
        window.properties_.get[:frontmost] rescue false
      end
    end
    
    # Sets options of the given object
    def set_options(object, options = {})
      options.each_pair do |option, value| 
        case option
        when :settings   # works for windows and tabs, for example :settings => "Grass"
          begin
            object.current_settings.set(@terminal.settings_sets[value])
          rescue Appscript::CommandError => e
            puts "Error: invalid settings set '#{value}'"
          end
        when :bounds # works only for windows
          # the only working sequence to restore window size and position! 
          object.bounds.set(value)
          object.frame.set(value)
          object.position.set(value)
        when :title
          # TODO: handle title option
        when :name
          # TODO: do nothing? 
        else # trying to apply any other option
          begin
            object.instance_eval(option.to_s).set(value)
          rescue Appscript::CommandError => e
            puts "Error setting '#{option} = #{value}' on #{object.inspect}"
            puts e.message
          end
        end
      end
    end


    private
    
    # These methods are here for reference so I can ponder later
    # how I could possibly use them.
    # And Currently aren't tested. =(
    
    # returns a window by the id
    def window_by_id(id)
      @windows.ID(id)
    end

    # grabs the window id.
    def window_id(window)
      window.id_.get
    end

    # set_window_title #<Window>, "hi"
    # Note: This sets all the windows to the same title.
    def set_window_title(window, title)
      window.custom_title.set(title)
    end
    
  end
end
