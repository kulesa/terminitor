module Terminitor
  # This AbstractCapture defines the basic methods that the Capture class should inherit
  class AbstractCapture
    # Captures settings of currently opened terminal windows and tabs,
    # generates .term file and saves it to the specified path
    def capture_settings
      capture_windows.inject("") do |config, w|
        config << generate_object_dsl('window', w) do |dsl|
          w[:tabs].each do |t|
            dsl << generate_object_dsl('tab', t, 4)
          end
        end
      end
    end
  
    # Returns hash of settings of currently opened windows and tabs.
    # Needs to be defined for specific platform
    def capture_windows
    end
    
    private
    
    # Ugly helper method to generate the .term file
    def generate_object_dsl(name, object, ident = 0, &block)
      dsl, margin = "", " "*ident

      params = object[:options].inject([]) do |params, option|
        params << ":#{option[0]} => #{option[1].inspect}"
      end.join(", ")

      dsl << margin + "#{name} #{params} do\n"
      yield(dsl) if block_given?
      dsl << margin + "end\n\n"
    end
  end
end