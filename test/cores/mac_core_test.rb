require File.expand_path('../../teststrap',__FILE__)

if platform?("darwin") # Only run test if it's darwin
  context "MacCore" do
    # Stub out the initialization
    setup do
      terminal = Object.new
      stub(terminal).windows { true }
      any_instance_of(Terminitor::MacCore) do |core|
        stub(core).app('Terminal')            { terminal  }
        stub(core).load_termfile('/path/to')  { true      }
      end 
    end
    setup { @mac_core = Terminitor::MacCore.new('/path/to') }

    context "terminal_process" do
      setup do
        process = Object.new
        mock(process).application_processes   { { "Terminal.app" => true }  }
        mock(@mac_core).app('System Events')  { process                     }
      end
      asserts("calls System Events") { @mac_core.terminal_process }
    end

    context "open_tab" do
      setup do
        process = Object.new
        mock(process).keystroke('t', :using => :command_down)
        mock(@mac_core).return_last_tab   { true    }
        mock(@mac_core).terminal_process  { process }
      end
      asserts("returns last tab") { @mac_core.open_tab }
    end
    
    context "open_tab with options" do
      setup do
        process = Object.new
        mock(process).keystroke('t', :using => :command_down)
        mock(@mac_core).set_options(true, :option1 => '1', :option2 => '2')        
        mock(@mac_core).return_last_tab.times(2)   { true    }
        mock(@mac_core).terminal_process  { process }
      end
      asserts("returns last tab") { @mac_core.open_tab(:option1 => '1', :option2 => '2') }
    end

    context "open_window" do
      setup do
        process = Object.new
        mock(process).keystroke('n', :using => :command_down)
        mock(@mac_core).return_last_tab   { true    }
        mock(@mac_core).terminal_process  { process }
      end
      asserts("returns last tab") { @mac_core.open_window }
    end

    context "open_window with options" do
      setup do
        process = Object.new
        window = Object.new
        tab = Object.new
        mock(process).keystroke('n', :using => :command_down)
        mock(@mac_core).set_options(window, :bounds => '1')
        mock(@mac_core).set_options(window, :settings => "2")       
        mock(@mac_core).active_window { window }.times(2)        
        mock(@mac_core).return_last_tab   { true    }
        mock(@mac_core).terminal_process  { process }
      end
      asserts("opens window with options") { @mac_core.open_window(:bounds => '1', :settings => '2')}
    end
    
    context "return_last_tab" do
      setup do
        window = Object.new
        tab    = Object.new
        mock(tab).get     { true  }
        mock(window).tabs { [tab] }
        mock(@mac_core).active_window { window }
      end
      asserts("returns tab") { @mac_core.return_last_tab }
    end

    context "execute_command" do
      setup do
        window = Object.new
        mock(window).do_script("hasta", :in => :la_vista) { true }
        mock(@mac_core).active_window { window }
      end
      asserts("baby") { @mac_core.execute_command('hasta', :in => :la_vista) }
    end

    context "active_window" do
      setup do
        terminal, windows, window, app_object = 4.times.collect { Object.new } # holy mother of somebody.
        stub(app_object).get      { {:frontmost => true}  }
        stub(window).properties_  { app_object            }
        stub(windows).get         { [window]              }  
        stub(terminal).windows    { windows               }
        any_instance_of(Terminitor::MacCore) do |core|
          stub(core).app('Terminal')            { terminal  }
          stub(core).load_termfile('/path/to')  { true      }
        end
      end
      asserts("gives me window") { Terminitor::MacCore.new('/path/to').active_window }
    end
    
    # context "set_options" do 
    #   TODO: add tests
    # end
  end
else
  context "MacCore" do
    puts "Nothing to do, you are not on OSX"
  end
end
