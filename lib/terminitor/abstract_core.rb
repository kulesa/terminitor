module Terminitor
  # This AbstractCore defines the basic methods that the Core should inherit
  class AbstractCore
    attr_accessor :terminal, :windows, :working_dir, :termfile

    # set the terminal object, windows, and load the Termfile.
    def initialize(path)
      @termfile = load_termfile(path)
    end

    # Executes the Termfile
    def process!
      term_setups = @termfile[:setup]
      term_windows = @termfile[:windows]
      run_in_window('default', term_windows['default'], :default => true) unless term_windows['default'].to_s.empty?
      term_windows.delete('default')
      term_windows.each_pair { |window_name, window_content| run_in_window(window_name, window_content) }
    end

    # this command will run commands in the designated window
    # run_in_window 'window1', {:tab1 => ['ls','ok']}
    def run_in_window(window_name, window_content, options = {})
      window_options = window_content[:options]      
      first_tab = true
      window_content[:tabs].each_pair do |tab_name, tab_content|
        # Open window on first 'tab' statement
        # first tab is already opened in the new window, so first tab should be
        # opened as a new tab in default window only
        tab_options = tab_content[:options]
        if first_tab && !options[:default]
          first_tab = false 
          window_options = Hash[window_options.to_a + tab_options.to_a] # safe merge
          tab = open_window(window_options.empty? ? nil : window_options)
        else
          tab = open_tab(tab_content[:options])
        end
        tab_content[:commands].insert(0,  "cd \"#{@working_dir}\"") unless @working_dir.to_s.empty?
        tab_content[:commands].each do |cmd|
          execute_command(cmd, :in => tab)
        end
      end
    end

    # Loads commands via the termfile and returns them as a hash
    # if it matches legacy yaml, parse as yaml, else use new dsl
    def load_termfile(path)
      File.extname(path) == '.yml' ? Terminitor::Yaml.new(path).to_hash : Terminitor::Dsl.new(path).to_hash
    end


    ## These methods are core specific methods that need to be defined.
    # yay.

    # Executes the Command
    # execute_command 'cd /path/to', {}
    def execute_command(cmd, options = {})
    end

    # Opens a new tab and returns itself.
    def open_tab(options = nil)
      @working_dir = Dir.pwd # pass in current directory.
    end

    # Opens a new window and returns the tab object.
    def open_window(options = nil)
      @working_dir = Dir.pwd # pass in current directory.      
    end

  end
end
