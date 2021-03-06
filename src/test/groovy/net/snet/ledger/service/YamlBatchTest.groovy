package net.snet.ledger.service

import com.google.common.base.Optional
import com.google.common.collect.Maps
import com.google.common.io.Resources
import spock.lang.Specification

/**
 * Created by sikorric on 2014-04-02.
 */
class YamlBatchTest extends Specification {
	def 'it should serialize to UTF-8'() {
	given:
		def map = Maps.newLinkedHashMap();
		map.id = 'ABC'
		map.text = 'ń'
		def yaml = new File(Resources.getResource('.').getFile(), 'testUtf8.yml')
		if (yaml.exists()) { yaml.delete() }
		assert ! yaml.exists()
		def batch = new YamlBatch(yaml)
		assert ! batch.isReady()
	when:
		batch.append(map)
		assert ! batch.isReady()
		batch.trailer(Optional.absent())
	then:
		batch.isReady()
		yaml.getText('UTF-8') == '---\nid: ABC\ntext: ń\n...\n'
	}

  def 'it should serialize items to yaml'() {
  given:
    def map = Maps.newLinkedHashMap();
    map.number = 'a123+'
	  map.quantity = 1.4
    def yaml = new File(Resources.getResource('.').getFile(), 'testSerialize.yml')
    if (yaml.exists()) { yaml.delete() }
    assert ! yaml.exists()
    def batch = new YamlBatch(yaml)
    assert ! batch.isReady()
  when:
    batch.header(Optional.of("\n# comment"))
    batch.append(map)
    batch.append(map)
    assert ! batch.isReady()
    batch.trailer(Optional.absent())
  then:
    batch.isReady()
    yaml.text == '''
# comment
---
number: a123+
quantity: 1.4
---
number: a123+
quantity: 1.4
...
'''
  }

	def 'it should serialize long text items to yaml'() {
	given:
		def map = Maps.newLinkedHashMap();
		map.name = 'Indywidualna Praktyka Lek. Wylacznie w Przedsiebiorstwie Podmiotu Leczniczego etc.'
		def yaml = new File(Resources.getResource('.').getFile(), 'testSerializeLongText.yml')
		if (yaml.exists()) { yaml.delete() }
		assert ! yaml.exists()
		def batch = new YamlBatch(yaml)
		assert ! batch.isReady()
	when:
		batch.append(map)
		assert ! batch.isReady()
		batch.trailer(Optional.absent())
	then:
		batch.isReady()
		yaml.text == '''---
name: Indywidualna Praktyka Lek. Wylacznie w Przedsiebiorstwie Podmiotu Leczniczego etc.
...
'''
		println yaml.text
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
