require 'test_helper'

class AqueductPostgresqlTest < ActiveSupport::TestCase
  test "truth" do
    assert_kind_of Module, Aqueduct::Postgresql
  end
end
