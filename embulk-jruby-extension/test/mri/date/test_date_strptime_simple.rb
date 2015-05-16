#
# how to use
# $ jruby -J-Xbootclasspath/a:embulk-jruby-extension/build/libs/embulk-jruby-extension-0.6.7.jar embulk-jruby-extension/test/mri/date/test_date_strptime_simple.rb
#
require 'test/unit'
require 'date'

require 'java'

class TestDateStrptime < Test::Unit::TestCase

  STRFTIME_2001_02_03 = {
    '%A'=>['Saturday',{:wday=>6}],
    '%a'=>['Sat',{:wday=>6}],
    '%B'=>['February',{:mon=>2}],
    '%b'=>['Feb',{:mon=>2}],
    '%c'=>['Sat Feb  3 00:00:00 2001',
      {:wday=>6,:mon=>2,:mday=>3,:hour=>0,:min=>0,:sec=>0,:year=>2001}],
    '%d'=>['03',{:mday=>3}],
    '%e'=>[' 3',{:mday=>3}],
    '%H'=>['00',{:hour=>0}],
    '%I'=>['12',{:hour=>0}],
    '%j'=>['034',{:yday=>34}],
    '%M'=>['00',{:min=>0}],
    '%m'=>['02',{:mon=>2}],
    '%p'=>['AM',{}],
    '%S'=>['00',{:sec=>0}],
    '%U'=>['04',{:wnum0=>4}],
    '%W'=>['05',{:wnum1=>5}],
    '%X'=>['00:00:00',{:hour=>0,:min=>0,:sec=>0}],
    '%x'=>['02/03/01',{:mon=>2,:mday=>3,:year=>2001}],
    '%Y'=>['2001',{:year=>2001}],
    '%y'=>['01',{:year=>2001}],
    '%Z'=>['+00:00',{:zone=>'+00:00',:offset=>0}],
    '%%'=>['%',{}],
    '%C'=>['20',{}],
    '%D'=>['02/03/01',{:mon=>2,:mday=>3,:year=>2001}],
    '%F'=>['2001-02-03',{:year=>2001,:mon=>2,:mday=>3}],
    '%G'=>['2001',{:cwyear=>2001}],
    '%g'=>['01',{:cwyear=>2001}],
    '%h'=>['Feb',{:mon=>2}],
    '%k'=>[' 0',{:hour=>0}],
    '%L'=>['000',{:sec_fraction=>0}],
    '%l'=>['12',{:hour=>0}],
    '%N'=>['000000000',{:sec_fraction=>0}],
    '%n'=>["\n",{}],
    '%P'=>['am',{}],
    '%Q'=>['981158400000',{:seconds=>981158400.to_r}],
    '%R'=>['00:00',{:hour=>0,:min=>0}],
    '%r'=>['12:00:00 AM',{:hour=>0,:min=>0,:sec=>0}],
    '%s'=>['981158400',{:seconds=>981158400}],
    '%T'=>['00:00:00',{:hour=>0,:min=>0,:sec=>0}],
    '%t'=>["\t",{}],
    '%u'=>['6',{:cwday=>6}],
    '%V'=>['05',{:cweek=>5}],
    '%v'=>[' 3-Feb-2001',{:mday=>3,:mon=>2,:year=>2001}],
    '%z'=>['+0000',{:zone=>'+0000',:offset=>0}],
    '%+'=>['Sat Feb  3 00:00:00 +00:00 2001',
      {:wday=>6,:mon=>2,:mday=>3,
	:hour=>0,:min=>0,:sec=>0,:zone=>'+00:00',:offset=>0,:year=>2001}],
  }

  STRFTIME_2001_02_03_CVS19 = {
  }

  STRFTIME_2001_02_03_GNUext = {
    '%:z'=>['+00:00',{:zone=>'+00:00',:offset=>0}],
    '%::z'=>['+00:00:00',{:zone=>'+00:00:00',:offset=>0}],
    '%:::z'=>['+00',{:zone=>'+00',:offset=>0}],
  }

  STRFTIME_2001_02_03.update(STRFTIME_2001_02_03_CVS19)
  STRFTIME_2001_02_03.update(STRFTIME_2001_02_03_GNUext)

  # def test__strptime

  def test__strptime__2
    parser = org.jruby.util.RubyDateParser.new

    h = parser.date_strptime_internal('%F', '2001-02-03').toMap
    assert_equal([2001,2,3], h.values_at("year","mon","mday"))

    h = parser.date_strptime_internal('%FT%XZ', '2001-02-03T12:13:14Z').toMap
    assert_equal([2001,2,3,12,13,14],
		 h.values_at("year","mon","mday","hour","min","sec"))

    assert_equal({}, parser.date_strptime_internal('', '').toMap)
    assert_equal({"leftover"=>"\s"*3}, parser.date_strptime_internal('', "\s"*3).toMap)
    assert_equal({"leftover"=>'x'}, parser.date_strptime_internal("\n", "\nx").toMap)
    assert_equal({}, parser.date_strptime_internal("\s"*3, '').toMap)
    assert_equal({}, parser.date_strptime_internal("\s"*3, "\s"*3).toMap)
    assert_equal({}, parser.date_strptime_internal("\tfoo\n\000\r", "\tfoo\n\000\r").toMap)
    assert_equal({}, parser.date_strptime_internal("foo\sbar", "foo\n\nbar").toMap)
    assert_equal({}, parser.date_strptime_internal("%\n", "%\n").toMap) # gnu
    assert_equal({}, parser.date_strptime_internal('%%%', '%%').toMap)
    #assert_equal({"wday"=>6}, parser.date_strptime_internal('%A'*1024 + ',', 'Saturday'*1024 + ',').toMap)
    #assert_equal({"wday"=>6}, parser.date_strptime_internal('%a'*1024 + ',', 'Saturday'*1024 + ',').toMap)
    assert_equal({}, parser.date_strptime_internal('Anton von Webern', 'Anton von Webern').toMap)
  end

  def test__strptime__3
    parser = org.jruby.util.RubyDateParser.new
    [
     # iso8601
     [['2001-02-03', '%Y-%m-%d'], [2001,2,3,nil,nil,nil,nil,nil,nil], __LINE__],
     [['2001-02-03T23:59:60', '%Y-%m-%dT%H:%M:%S'], [2001,2,3,23,59,60,nil,nil,nil], __LINE__],
     [['2001-02-03T23:59:60+09:00', '%Y-%m-%dT%H:%M:%S%Z'], [2001,2,3,23,59,60,'+09:00',9*3600,nil], __LINE__],
     [['-2001-02-03T23:59:60+09:00', '%Y-%m-%dT%H:%M:%S%Z'], [-2001,2,3,23,59,60,'+09:00',9*3600,nil], __LINE__],
     [['+012345-02-03T23:59:60+09:00', '%Y-%m-%dT%H:%M:%S%Z'], [12345,2,3,23,59,60,'+09:00',9*3600,nil], __LINE__],
     [['-012345-02-03T23:59:60+09:00', '%Y-%m-%dT%H:%M:%S%Z'], [-12345,2,3,23,59,60,'+09:00',9*3600,nil], __LINE__],

     # ctime(3), asctime(3)
     [['Thu Jul 29 14:47:19 1999', '%c'], [1999,7,29,14,47,19,nil,nil,4], __LINE__],
     [['Thu Jul 29 14:47:19 -1999', '%c'], [-1999,7,29,14,47,19,nil,nil,4], __LINE__],

     # date(1)
     [['Thu Jul 29 16:39:41 EST 1999', '%a %b %d %H:%M:%S %Z %Y'], [1999,7,29,16,39,41,'EST',-5*3600,4], __LINE__],
     [['Thu Jul 29 16:39:41 MET DST 1999', '%a %b %d %H:%M:%S %Z %Y'], [1999,7,29,16,39,41,'MET DST',2*3600,4], __LINE__],
     [['Thu Jul 29 16:39:41 AMT 1999', '%a %b %d %H:%M:%S %Z %Y'], [1999,7,29,16,39,41,'AMT',nil,4], __LINE__],
     [['Thu Jul 29 16:39:41 AMT -1999', '%a %b %d %H:%M:%S %Z %Y'], [-1999,7,29,16,39,41,'AMT',nil,4], __LINE__],
     [['Thu Jul 29 16:39:41 GMT+09 1999', '%a %b %d %H:%M:%S %Z %Y'], [1999,7,29,16,39,41,'GMT+09',9*3600,4], __LINE__],
     [['Thu Jul 29 16:39:41 GMT+0908 1999', '%a %b %d %H:%M:%S %Z %Y'], [1999,7,29,16,39,41,'GMT+0908',9*3600+8*60,4], __LINE__],
     [['Thu Jul 29 16:39:41 GMT+090807 1999', '%a %b %d %H:%M:%S %Z %Y'], [1999,7,29,16,39,41,'GMT+090807',9*3600+8*60+7,4], __LINE__],
     [['Thu Jul 29 16:39:41 GMT-09 1999', '%a %b %d %H:%M:%S %Z %Y'], [1999,7,29,16,39,41,'GMT-09',-9*3600,4], __LINE__],
     [['Thu Jul 29 16:39:41 GMT-09:08 1999', '%a %b %d %H:%M:%S %Z %Y'], [1999,7,29,16,39,41,'GMT-09:08',-9*3600-8*60,4], __LINE__],
     [['Thu Jul 29 16:39:41 GMT-09:08:07 1999', '%a %b %d %H:%M:%S %Z %Y'], [1999,7,29,16,39,41,'GMT-09:08:07',-9*3600-8*60-7,4], __LINE__],
     [['Thu Jul 29 16:39:41 GMT-3.5 1999', '%a %b %d %H:%M:%S %Z %Y'], [1999,7,29,16,39,41,'GMT-3.5',-3*3600-30*60,4], __LINE__],
     [['Thu Jul 29 16:39:41 GMT-3,5 1999', '%a %b %d %H:%M:%S %Z %Y'], [1999,7,29,16,39,41,'GMT-3,5',-3*3600-30*60,4], __LINE__],
     [['Thu Jul 29 16:39:41 Mountain Daylight Time 1999', '%a %b %d %H:%M:%S %Z %Y'], [1999,7,29,16,39,41,'Mountain Daylight Time',-6*3600,4], __LINE__],
     [['Thu Jul 29 16:39:41 E. Australia Standard Time 1999', '%a %b %d %H:%M:%S %Z %Y'], [1999,7,29,16,39,41,'E. Australia Standard Time',10*3600,4], __LINE__],

     # rfc822
     [['Thu, 29 Jul 1999 09:54:21 UT', '%a, %d %b %Y %H:%M:%S %Z'], [1999,7,29,9,54,21,'UT',0,4], __LINE__],
     [['Thu, 29 Jul 1999 09:54:21 GMT', '%a, %d %b %Y %H:%M:%S %Z'], [1999,7,29,9,54,21,'GMT',0,4], __LINE__],
     [['Thu, 29 Jul 1999 09:54:21 PDT', '%a, %d %b %Y %H:%M:%S %Z'], [1999,7,29,9,54,21,'PDT',-7*3600,4], __LINE__],
     [['Thu, 29 Jul 1999 09:54:21 z', '%a, %d %b %Y %H:%M:%S %Z'], [1999,7,29,9,54,21,'z',0,4], __LINE__],
     [['Thu, 29 Jul 1999 09:54:21 +0900', '%a, %d %b %Y %H:%M:%S %Z'], [1999,7,29,9,54,21,'+0900',9*3600,4], __LINE__],
     [['Thu, 29 Jul 1999 09:54:21 +0430', '%a, %d %b %Y %H:%M:%S %Z'], [1999,7,29,9,54,21,'+0430',4*3600+30*60,4], __LINE__],
     [['Thu, 29 Jul 1999 09:54:21 -0430', '%a, %d %b %Y %H:%M:%S %Z'], [1999,7,29,9,54,21,'-0430',-4*3600-30*60,4], __LINE__],
     [['Thu, 29 Jul -1999 09:54:21 -0430', '%a, %d %b %Y %H:%M:%S %Z'], [-1999,7,29,9,54,21,'-0430',-4*3600-30*60,4], __LINE__],

     # etc
     [['06-DEC-99', '%d-%b-%y'], [1999,12,6,nil,nil,nil,nil,nil,nil], __LINE__],
     [['sUnDay oCtoBer 31 01', '%A %B %d %y'], [2001,10,31,nil,nil,nil,nil,nil,0], __LINE__],
     [["October\t\n\v\f\r 15,\t\n\v\f\r99", '%B %d, %y'], [1999,10,15,nil,nil,nil,nil,nil,nil], __LINE__],
     [["October\t\n\v\f\r 15,\t\n\v\f\r99", '%B%t%d,%n%y'], [1999,10,15,nil,nil,nil,nil,nil,nil], __LINE__],

     [['09:02:11 AM', '%I:%M:%S %p'], [nil,nil,nil,9,2,11,nil,nil,nil], __LINE__],
     [['09:02:11 A.M.', '%I:%M:%S %p'], [nil,nil,nil,9,2,11,nil,nil,nil], __LINE__],
     [['09:02:11 PM', '%I:%M:%S %p'], [nil,nil,nil,21,2,11,nil,nil,nil], __LINE__],
     [['09:02:11 P.M.', '%I:%M:%S %p'], [nil,nil,nil,21,2,11,nil,nil,nil], __LINE__],

     [['12:33:44 AM', '%r'], [nil,nil,nil,0,33,44,nil,nil,nil], __LINE__],
     [['01:33:44 AM', '%r'], [nil,nil,nil,1,33,44,nil,nil,nil], __LINE__],
     [['11:33:44 AM', '%r'], [nil,nil,nil,11,33,44,nil,nil,nil], __LINE__],
     [['12:33:44 PM', '%r'], [nil,nil,nil,12,33,44,nil,nil,nil], __LINE__],
     [['01:33:44 PM', '%r'], [nil,nil,nil,13,33,44,nil,nil,nil], __LINE__],
     [['11:33:44 PM', '%r'], [nil,nil,nil,23,33,44,nil,nil,nil], __LINE__],

     [['11:33:44 PM AMT', '%I:%M:%S %p %Z'], [nil,nil,nil,23,33,44,'AMT',nil,nil], __LINE__],
     [['11:33:44 P.M. AMT', '%I:%M:%S %p %Z'], [nil,nil,nil,23,33,44,'AMT',nil,nil], __LINE__],

     [['fri1feb034pm+5', '%a%d%b%y%H%p%Z'], [2003,2,1,16,nil,nil,'+5',5*3600,5]]
    ].each do |x, y|
      h = parser.date_strptime_internal(x[1], x[0]).toMap
      a = h.values_at("year","mon","mday","hour","min","sec","zone","offset","wday")
      if y[1] == -1
	a[1] = -1
	a[2] = h["yday"]
      end
      assert_equal(y, a, [x, y, a].inspect)
    end
  end

  def test__strptime__width
    parser = org.jruby.util.RubyDateParser.new
    [
     [['99', '%y'], [1999,nil,nil,nil,nil,nil,nil,nil,nil], __LINE__],
     [['01', '%y'], [2001,nil,nil,nil,nil,nil,nil,nil,nil], __LINE__],
     [['19 99', '%C %y'], [1999,nil,nil,nil,nil,nil,nil,nil,nil], __LINE__],
     [['20 01', '%C %y'], [2001,nil,nil,nil,nil,nil,nil,nil,nil], __LINE__],
     [['30 99', '%C %y'], [3099,nil,nil,nil,nil,nil,nil,nil,nil], __LINE__],
     [['30 01', '%C %y'], [3001,nil,nil,nil,nil,nil,nil,nil,nil], __LINE__],
     [['1999', '%C%y'], [1999,nil,nil,nil,nil,nil,nil,nil,nil], __LINE__],
     [['2001', '%C%y'], [2001,nil,nil,nil,nil,nil,nil,nil,nil], __LINE__],
     [['3099', '%C%y'], [3099,nil,nil,nil,nil,nil,nil,nil,nil], __LINE__],
     [['3001', '%C%y'], [3001,nil,nil,nil,nil,nil,nil,nil,nil], __LINE__],

     [['20060806', '%Y'], [20060806,nil,nil,nil,nil,nil,nil,nil,nil], __LINE__],
     [['20060806', "%Y\s"], [20060806,nil,nil,nil,nil,nil,nil,nil,nil], __LINE__],
     [['20060806', '%Y%m%d'], [2006,8,6,nil,nil,nil,nil,nil,nil], __LINE__],
     [['2006908906', '%Y9%m9%d'], [2006,8,6,nil,nil,nil,nil,nil,nil], __LINE__],
     [['12006 08 06', '%Y %m %d'], [12006,8,6,nil,nil,nil,nil,nil,nil], __LINE__],
     [['12006-08-06', '%Y-%m-%d'], [12006,8,6,nil,nil,nil,nil,nil,nil], __LINE__],
     [['200608 6', '%Y%m%e'], [2006,8,6,nil,nil,nil,nil,nil,nil], __LINE__],

     [['2006333', '%Y%j'], [2006,-1,333,nil,nil,nil,nil,nil,nil], __LINE__],
     [['20069333', '%Y9%j'], [2006,-1,333,nil,nil,nil,nil,nil,nil], __LINE__],
     [['12006 333', '%Y %j'], [12006,-1,333,nil,nil,nil,nil,nil,nil], __LINE__],
     [['12006-333', '%Y-%j'], [12006,-1,333,nil,nil,nil,nil,nil,nil], __LINE__],

     [['232425', '%H%M%S'], [nil,nil,nil,23,24,25,nil,nil,nil], __LINE__],
     [['23924925', '%H9%M9%S'], [nil,nil,nil,23,24,25,nil,nil,nil], __LINE__],
     [['23 24 25', '%H %M %S'], [nil,nil,nil,23,24,25,nil,nil,nil], __LINE__],
     [['23:24:25', '%H:%M:%S'], [nil,nil,nil,23,24,25,nil,nil,nil], __LINE__],
     [[' 32425', '%k%M%S'], [nil,nil,nil,3,24,25,nil,nil,nil], __LINE__],
     [[' 32425', '%l%M%S'], [nil,nil,nil,3,24,25,nil,nil,nil], __LINE__],

     [['FriAug', '%a%b'], [nil,8,nil,nil,nil,nil,nil,nil,5], __LINE__],
     [['FriAug', '%A%B'], [nil,8,nil,nil,nil,nil,nil,nil,5], __LINE__],
     [['FridayAugust', '%A%B'], [nil,8,nil,nil,nil,nil,nil,nil,5], __LINE__],
     [['FridayAugust', '%a%b'], [nil,8,nil,nil,nil,nil,nil,nil,5], __LINE__],
    ].each do |x,y,l|
      h = parser.date_strptime_internal(x[1], x[0]).toMap
      a = (h || {}).values_at("year","mon","mday","hour","min","sec","zone","offset","wday")
      if y[1] == -1
	a[1] = -1
	a[2] = h["yday"]
      end
      assert_equal(y, a, format('<failed at line %d>', l))
    end
  end

  def test__strptime__fail
    parser = org.jruby.util.RubyDateParser.new

    assert_not_nil(parser.date_strptime_internal('%Y.', '2001.').toMap)
    assert_not_nil(parser.date_strptime_internal('%Y.', "2001.\s").toMap)
    assert_not_nil(parser.date_strptime_internal("%Y.\s", '2001.').toMap)
    assert_not_nil(parser.date_strptime_internal("%Y.\s", "2001.\s").toMap)

    assert_nil(parser.date_strptime_internal('%Y.', '2001'))
    assert_nil(parser.date_strptime_internal('%Y.', "2001\s"))
    assert_nil(parser.date_strptime_internal("%Y.\s", '2001'))
    assert_nil(parser.date_strptime_internal("%Y.\s", "2001\s"))

    assert_nil(parser.date_strptime_internal('%Y-%m-%d', '2001-13-31'))
    assert_nil(parser.date_strptime_internal('%Y-%m-%d', '2001-12-00'))
    assert_nil(parser.date_strptime_internal('%Y-%m-%d', '2001-12-32'))
    assert_nil(parser.date_strptime_internal('%Y-%m-%e', '2001-12-00'))
    assert_nil(parser.date_strptime_internal('%Y-%m-%e', '2001-12-32'))
    assert_nil(parser.date_strptime_internal('%y-%m-%d', '2001-12-31'))

    assert_nil(parser.date_strptime_internal('%Y-%j', '2004-000'))
    assert_nil(parser.date_strptime_internal('%Y-%j', '2004-367'))
    assert_nil(parser.date_strptime_internal('%Y-%j', '2004-366'))

    assert_not_nil(parser.date_strptime_internal('%H:%M:%S', '24:59:59'))
    assert_not_nil(parser.date_strptime_internal('%H:%M:%S', '24:59:59'))
    assert_not_nil(parser.date_strptime_internal('%H:%M:%S', '24:59:60'))
    assert_not_nil(parser.date_strptime_internal('%H:%M:%S', '24:59:60'))

    assert_nil(parser.date_strptime_internal('%H:%M:%S', '24:60:59'))
    assert_nil(parser.date_strptime_internal('%k:%M:%S', '24:60:59'))
    assert_nil(parser.date_strptime_internal('%H:%M:%S', '24:59:61'))
    assert_nil(parser.date_strptime_internal('%k:%M:%S', '24:59:61'))
    assert_nil(parser.date_strptime_internal('%I:%M:%S', '00:59:59'))
    assert_nil(parser.date_strptime_internal('%I:%M:%S', '13:59:59'))
    assert_nil(parser.date_strptime_internal('%I:%M:%S', '00:59:59'))
    assert_nil(parser.date_strptime_internal('%I:%M:%S', '13:59:59'))

    assert_not_nil(parser.date_strptime_internal('%U', '0'))
    assert_nil(parser.date_strptime_internal('%U', '54'))
    assert_not_nil(parser.date_strptime_internal('%W', '0'))
    assert_nil(parser.date_strptime_internal('%W', '54'))
    assert_nil(parser.date_strptime_internal('%V', '0'))
    assert_nil(parser.date_strptime_internal('%V', '54'))
    assert_nil(parser.date_strptime_internal('%u', '0'))
    assert_not_nil(parser.date_strptime_internal('%u', '7'))
    assert_not_nil(parser.date_strptime_internal('%w', '0'))
    assert_nil(parser.date_strptime_internal('%w', '7'))

    assert_nil(parser.date_strptime_internal('%A', 'Sanday'))
    assert_nil(parser.date_strptime_internal('%B', 'Jenuary'))
    assert_not_nil(parser.date_strptime_internal('%A', 'Sundai'))
    assert_not_nil(parser.date_strptime_internal('%B', 'Januari'))
    assert_nil(parser.date_strptime_internal('%A,', 'Sundai,'))
    assert_nil(parser.date_strptime_internal('%B,', 'Januari,'))
  end

  def test_given_string
    s = '2001-02-03T04:05:06Z'
    s0 = s.dup

    parser = org.jruby.util.RubyDateParser.new
    compiled = parser.compilePattern('%FT%T%Z')
    assert_not_equal({}, parser.date_strptime_internal(compiled, s).toMap)
    assert_equal(s0, s)
  end

end