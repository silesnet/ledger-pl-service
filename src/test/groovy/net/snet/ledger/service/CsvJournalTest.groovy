package net.snet.ledger.service

import com.google.common.io.Resources
import spock.lang.Specification

/**
 * Created by sikorric on 2014-04-04.
 */
class CsvJournalTest extends Specification {
  def 'it should parser journal file'() {
  given:
    def file = new File(Resources.getResource('journal-test.jrn').getFile())
  when:
    def journal = new CsvJournal(file)
  then:
    journal.hasNext()
    journal.next().sequence() == 1
    journal.hasNext()
    journal.next().id() == '1002'
    journal.hasNext()
    journal.next().message() == 'FAILED'
    journal.hasNext()
    journal.next().isOk()
    !journal.hasNext()
  }
}
