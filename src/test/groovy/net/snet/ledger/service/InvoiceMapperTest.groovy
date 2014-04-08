package net.snet.ledger.service

import spock.lang.Specification

/**
 * Created by admin on 7.4.14.
 */
class InvoiceMapperTest extends Specification {
	def pctToIdMap = [ 23: 100001 ]

	def 'it should map SIS invoice to InsERT invoice'() {
	given:
		def sis = fixture()
		def mapper = new InvoiceMapper(pctToIdMap)
  when:
		def insert = mapper.map(sis)
	then:
		insert.number == '4451'
		insert.customerId == 'AB-5578'
		insert.invoiceDate == '2014-04-04'
		insert.dueDate == '2014-04-18'
		insert.deliveryDate == '2014-04-30'
		insert.items[0].name == 'WIRELESSmax  10/2 Mbps, 04/2014'
		insert.items[0].unitPrice == 48.0
		insert.items[0].quantity == 1.0
		insert.items[0].unit == 'mies.'
		insert.items[0].vatId == 100001
		insert.items[0].vatPct == 23
	}

	def 'it should map item.name when period_to is null'() {
		given:
			def sis = fixture()
			sis.remove('period_to')
			sis.period_from = 1406303200000

		def mapper = new InvoiceMapper(pctToIdMap)
		when:
			def insert = mapper.map(sis)
		then:
			insert.items[0].name == 'WIRELESSmax  10/2 Mbps, 07/2014'
	}

	def 'it should map unit when is_display_unit is false'() {
		given:
			def sis = fixture()
			sis.lines[0].is_display_unit = false
			def mapper = new InvoiceMapper(pctToIdMap)
		when:
			def insert = mapper.map(sis)
		then:
			insert.items[0].unit == 'szt.'
	}

	def fixture() {
		return [
				number: "201404451",
				billing_date: 1396562400000,
				purge_date: 1397772000000,
				period_from: 1396303200000,
				period_to: 1398808800000,
				vat: 23,
				lines: [
						[
								text : "WIRELESSmax  10/2 Mbps",
								amount : 1.0,
								price : 48,
								is_display_unit : true
						]
				],
				customer: [
						symbol : "AB-5578"
				]
		]
	}
}
