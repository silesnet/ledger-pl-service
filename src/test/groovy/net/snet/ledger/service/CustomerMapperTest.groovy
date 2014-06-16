package net.snet.ledger.service

import spock.lang.Specification

/**
 * Created by admin on 15.6.14.
 */
class CustomerMapperTest extends Specification {
	def 'it should map residential customer'() {
	given:
		def sis = fixture()
		def mapper = new CustomerMapper()
	when:
		def yml = mapper.map(sis)
	then:
		yml.id == 1
		yml.isNew
		yml.surrogateId == 'PL-4307'
		yml.isBusiness == false
		yml.name == 'Marie Kastnerová                                ...'
		yml.fullName == 'Marie Kastnerová                                  XZ - and partners'
		yml.publicId == '9912310001'
		! yml.containsKey('vatId')
		yml.address.street == 'Vrchlického'
		yml.address.streetNumber == '1613'
		yml.address.premiseNumber == '23'
		yml.address.city == 'Šumná'
		yml.address.postalCode == '671 02'
		yml.address.country == 'PL'
		yml.email == 'MarieKastnerova@jourrapide.com'
		yml.phone == '548 780 242'
		yml.bankAccount == '12345679'
	}

	def 'it should map business customer'() {
		given:
		def sis = fixture()
		sis.dic = '987654'
		def mapper = new CustomerMapper()
		when:
		def yml = mapper.map(sis)
		then:
		yml.id == 1
		yml.isNew
		yml.surrogateId == 'PL-4307'
		yml.isBusiness == true
		yml.name == 'Marie Kastnerová                                ...'
		yml.fullName == 'Marie Kastnerová                                  XZ - and partners'
		yml.publicId == '9912310001'
		yml.vatId == '987654'
		yml.address.street == 'Vrchlického'
		yml.address.streetNumber == '1613'
		yml.address.premiseNumber == '23'
		yml.address.city == 'Šumná'
		yml.address.postalCode == '671 02'
		yml.address.country == 'PL'
		yml.email == 'MarieKastnerova@jourrapide.com'
		yml.phone == '548 780 242'
		yml.bankAccount == '12345679'
	}

	def fixture() {
		return [
				id : 1,
				symbol : "PL-4307",
				name : "Marie Kastnerová                                  XZ",
				supplementary_name : "and partners",
				street : "Vrchlického 1613/23",
				city : "Šumná",
				postal_code : "671 02",
				country : 20,
				email : "MarieKastnerova@jourrapide.com",
				phone : "548 780 242",
				public_id : "9912310001",
				dic : "",
				account_no : "12345679",
				bank_no : "",
				"synchronized" : null
		]
	}
}
