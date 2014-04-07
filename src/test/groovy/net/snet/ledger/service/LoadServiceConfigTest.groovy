package net.snet.ledger.service

import spock.lang.Specification

/**
 * Created by admin on 7.4.14.
 */
class LoadServiceConfigTest extends Specification {
	def 'it should build LoadServiceConfiguration'() {
	given:
		def builder = new LoadServiceConfig.Builder();
		def mapper = Mock(Mapper)
		def batchFactory = Mock(BatchFactory)
		def cmd = new File('.')
	when:
		def config = builder
									.withPollUrl('pollUrl')
									.withMapper(mapper)
									.withBatchFactory(batchFactory)
									.withLoadCommand(cmd)
									.build()
	then:
		config.pollUrl() == 'pollUrl'
		config.mapper() == mapper
		config.batchFactory() == batchFactory
		config.loadCommand() == cmd
	}
}
