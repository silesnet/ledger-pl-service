package net.snet.ledger.service

import spock.lang.Specification

/**
 * Created by sikorric on 2014-05-21.
 */
class YamlDumperTest extends Specification {
  def 'it should dump string'() {
  given:
    def dumper = new YamlDumper()
  expect:
    dumper.dump(value) == "--- $dump\n"
  where:
    value | dump
    'alfa' | 'alfa'
  }
}
