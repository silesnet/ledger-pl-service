package net.snet.ledger.service

import com.google.common.collect.Maps
import spock.lang.Specification

/**
 * Created by sikorric on 2014-04-02.
 */
class YamlBatchTest extends Specification {
  def 'it should serialize map to yaml'() {
  given:
    def map = Maps.newHashMap();
    map.number = 'a123'
    def batch = new YamlBatch()
  when:
    batch.add(map)
  then:
    false
  }
}
