package net.snet.ledger.service

import com.google.common.io.Resources
import spock.lang.Specification

/**
 * Created by sikorric on 2014-04-03.
 */
class YamlBatchFactoryTest extends Specification {
  def 'it should assign batch file name according to prefix'() {
  given:
    def prefix = new File(Resources.getResource('.').getFile(), 'test-load-')
    def factory = new YamlBatchFactory(prefix)
  when:
    def batch = factory.newBatch()
  then:
    prefix.parentFile.equals(batch.file().getParentFile())
    batch.file().getName().startsWith(prefix.getName())
  }

  def 'it should create working directory if it does not exists'() {
  given:
    def prefix = new File(Resources.getResource('.').getFile(), 'load/test-load-')
    if (prefix.getParentFile().exists()) {
      prefix.getParentFile().deleteDir()
    }
    assert ! prefix.getParentFile().exists()
    def factory = new YamlBatchFactory(prefix)
  when:
    factory.newBatch()
  then:
    prefix.getParentFile().exists()
  }

}
