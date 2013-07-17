module Aqueduct
  module Postgresql
    module VERSION
      MAJOR = 0
      MINOR = 2
      TINY = 0
      BUILD = nil # nil, "pre", "rc", "rc2"

      STRING = [MAJOR, MINOR, TINY, BUILD].compact.join('.')
    end
  end
end
