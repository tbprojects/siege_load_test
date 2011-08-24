module Testing
  module SiegeLoadTestsHelper

    def asset_link(path)
      "/testing/assets/#{path}"
    end

    # menu highlighting
    def highlight(name)
      (@highlight == name) ? ' highlighted' : nil
    end

    def f_prec(text)
      if text.is_a? Float
        "%.2f" % text
      else
        text
      end
    end

    def milliseconds_to_wait(seconds)
      (time + 5) * 1000
    end

  end
end
