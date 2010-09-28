require File.expand_path('../teststrap', __FILE__)

context "AbstractCore" do

  context "process!" do
    context "without default" do
      setup do
        any_instance_of(Terminitor::AbstractCore) do |core|
          stub(core).load_termfile('/path/to')  { {:windows => {'window1' => {'tab1' => ['ls', 'ok']}, 'default' => [] }, :options => {} } }
        end
      end
      setup { @core = Terminitor::AbstractCore.new('/path/to') }
      setup { mock(@core).run_in_window('window1', {'tab1' => ['ls', 'ok']}) }
      asserts("ok") { @core.process! }
    end

    context "with default" do
      setup do
        any_instance_of(Terminitor::AbstractCore) do |core|
          stub(core).load_termfile('/path/to')  { {:windows => {'window1' => {'tab1' => ['ls', 'ok']}, 'default' => {'tab0' => ['echo']} } } }
        end
      end
      setup { @core = Terminitor::AbstractCore.new('/path/to') }
      setup { mock(@core).run_in_window('default',{'tab0'=>['echo']}, :default => true) }
      setup { mock(@core).run_in_window('window1', {'tab1' => ['ls', 'ok']}) }
      asserts("ok") { @core.process! }
    end

  end

  context "run_in_window" do
    context "without options" do 
      setup do
        any_instance_of(Terminitor::AbstractCore) do |core|
          stub(core).load_termfile('/path/to')  { {:options => {}} }
        end
        @core = Terminitor::AbstractCore.new('/path/to')
      end

      context "without default" do
        setup { mock(@core).open_window(nil)          { true  } }
        setup { mock(@core).open_tab(nil)             { true  } }
        setup { mock(@core).execute_command('ls', :in => true)  }
        setup { mock(@core).execute_command('ok', :in => true)  }
        asserts("ok") { @core.run_in_window('window1', {'tab1' => ['ls','ok']}) }
      end

      context "with default" do
        setup { mock(@core).open_tab(nil) { true  } }
        setup { mock(@core).execute_command('ls', :in => true)  }
        setup { mock(@core).execute_command('ok', :in => true)  }
        asserts("ok") { @core.run_in_window('window1', {'tab' => ['ls','ok']}, :default => true) }
      end

      context "with working_dir" do
        setup { stub(Dir).pwd { '/tmp/path' } }
        setup { mock(@core).execute_command("cd \"/tmp/path\"", :in => '/tmp/path')  }
        setup { mock(@core).execute_command('ls', :in => '/tmp/path')  }
        asserts("ok") { @core.run_in_window('window1', {'tab' => ['ls']}) }
      end
    end
    
    context "with options" do 
      setup do
        any_instance_of(Terminitor::AbstractCore) do |core|
          stub(core).load_termfile('/path/to')  { {:options => {'window1'=>{:name => 'main'}, 'tab1'=>{:settings=>'cool', :name=>'named tab'} } } }
        end
        @core = Terminitor::AbstractCore.new('/path/to')
      end
      
      setup { mock(@core).open_window(:name => 'main')  { true  } }
      setup { mock(@core).open_tab(:settings => 'cool', :name => 'named tab')    { true  } }
      setup { mock(@core).execute_command('ls', :in => true)  }
      setup { mock(@core).execute_command('ok', :in => true)  }
      asserts("ok") { @core.run_in_window('window1', {'tab1' => ['ls','ok']}) }
    end
  end



end
