package net.snet.ledger.service

import com.google.common.base.Optional
import com.google.common.collect.Maps
import com.google.common.io.Resources
import spock.lang.Specification

/**
 * Created by sikorric on 2014-04-02.
 */
class YamlBatchTest extends Specification {
  def 'it should serialize items to yaml'() {
  given:
    def map = Maps.newHashMap();
    map.number = 'a123+'
    def yaml = new File(Resources.getResource('.').getFile(), 'testSerialize.yml')
    if (yaml.exists()) { yaml.delete() }
    def batch = new YamlBatch(yaml)
    assert ! batch.isReady()
  when:
    batch.header(Optional.of("# comment"))
    batch.append(map)
    batch.append(map)
    assert ! batch.isReady()
    batch.trailer(Optional.absent())
  then:
    batch.isReady()
    yaml.text == '''\
# comment
---
number: "a123+"
---
number: "a123+"
...
'''
  }

  def 'it should provide batch file'() {
  given:
    def yaml = new File(Resources.getResource('.').getFile(), 'testSerialize.yml')
    if (yaml.exists()) { yaml.delete() }
    assert ! yaml.exists()
  when:
    def batch = new YamlBatch(yaml)
  then:
    batch.file().exists()
  }
}
