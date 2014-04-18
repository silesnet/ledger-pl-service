package net.snet.ledger.service

import com.google.common.io.Resources
import spock.lang.Specification

/**
 * Created by sikorric on 2014-04-04.
 */
class InsertGtLoaderTest extends Specification {
  def 'it should load batch to insert gt'() {
  given:
    def cmd = new File(Resources.getResource('load-invoices-dry.cmd').getFile())
    assert cmd.exists()
    def insertGtConf = new File('subiekt.xml')
    def batch = new File(Resources.getResource('invoice-test-load.yml').getFile())
    def loader = new InsertGtLoader(cmd, insertGtConf)
  when:
    def journal = loader.load(batch)
  then:
    journal.hasNext()
    journal.next().isOk()
    journal.hasNext()
    journal.next().sequence() == 2
    !journal.hasNext()
  }
}
