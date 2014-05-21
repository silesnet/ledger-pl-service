package net.snet.ledger.service

import spock.lang.Specification
import spock.lang.Unroll

/**
 * Created by sikorric on 2014-05-21.
 */
class YamlDumperTest extends Specification {
  @Unroll
  def "it should dump '#value'"() {
  given:
    def dumper = new YamlDumper()
  expect:
    dumper.dump(value) == "--- $dump\n"
  where:
    value | dump
    'alfa' | 'alfa'
    '"alfa"' | '\'"alfa"\''
    '\'alfa\'' | '\'\'\'alfa\'\'\''
    '\'' | '\'\'\'\''
    '"' | '\'"\''
    'áčžůÁČŽŮąężńłĄĘŻŃŁ!?@#$^&*()/+-,;.<>[]|{}~`\\\'"' | 'áčžůÁČŽŮąężńłĄĘŻŃŁ!?@#$^&*()/+-,;.<>[]|{}~`\\\'"'
    '"áčžůÁČŽŮąężńłĄĘŻŃŁ!?@#$^&*()/+-,;.<>[]|{}~`\\\'""' | '\'"áčžůÁČŽŮąężńłĄĘŻŃŁ!?@#$^&*()/+-,;.<>[]|{}~`\\\'\'""\''
    'a\nb' | '|-\n  a\n  b' // should replace \n, \t, \r in values with spaces
    "a\nb" | '|-\n  a\n  b'
    'a\tb' | '"a\\tb"'
    "a\tb" | '"a\\tb"'
    "a\rb" | '"a\\rb"'
    '' | '\'\''
    '123' | '\'123\''
  }

  def 'it should dump long text value without wrapping'() {
  given:
    def dumper = new YamlDumper()
    def largeText = '123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 '
  when:
    def dump = dumper.dump([key: largeText])
  then:
    dump == "---\nkey: '$largeText'\n"
  }
}
