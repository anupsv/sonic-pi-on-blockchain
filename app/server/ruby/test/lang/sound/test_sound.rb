#--
# This file is part of Sonic Pi: http://sonic-pi.net
# Full project source: https://github.com/samaaron/sonic-pi
# License: https://github.com/samaaron/sonic-pi/blob/main/LICENSE.md
#
# Copyright 2013, 2014, 2015, 2016 by Sam Aaron (http://sam.aaron.name).
# All rights reserved.
#
# Permission is granted for use, copying, modification, and
# distribution of modified versions of this work as long as this
# notice is included.
#++

require_relative "../../setup_test"
require_relative "../../../lib/sonicpi/lang/sound"

module SonicPi
  class SoundTester < Minitest::Test

    def setup
      @mock_sound = Object.new
      @mock_sound.extend(Lang::Sound)
    end

    def test_truthy
      assert_equal(false, @mock_sound.truthy?(0))
      assert_equal(true, @mock_sound.truthy?(1))
      assert_equal(true, @mock_sound.truthy?(-1))
      assert_equal(true, @mock_sound.truthy?(0.01))

      assert_equal(false, @mock_sound.truthy?(nil))

      assert_equal(true, @mock_sound.truthy?(true))
      assert_equal(false, @mock_sound.truthy?(false))

      proc = Proc.new {true}
      assert_equal(true, @mock_sound.truthy?(proc))
    end

    def test_should_trigger
      h = {on: true, a: 123, c: "d"}
      assert_equal(true, @mock_sound.should_trigger?(h))
      assert_equal(false, h.has_key?(:on))

      h = {on: false, a: 123, c: "d"}
      assert_equal(false, @mock_sound.should_trigger?(h))
      assert_equal(false, h.has_key?(:on))

      h = {a: 123, c: "d"}
      assert_equal(true, @mock_sound.should_trigger?(h))
    end

    def test_sample_duration
        @mock_sound.stub :resolve_sample_path, nil do
            assert_raises(ArgumentError) { @mock_sound.sample_duration(["a/directory", "bogus_file_name"]) }
        end
    end
  end
end
