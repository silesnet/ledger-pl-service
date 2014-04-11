package net.snet.ledger.service

import spock.lang.Specification

/**
 * Created by admin on 4.4.14.
 */
class UrlTest extends Specification {

	def 'it should get resource name from url'() {
		def url = new URL('http://localhost:1234/api/v2/posts?qn=new')
		def name = new File(url.getPath()).getName()
	expect:
		name == 'posts'
	}

  def 'it should clone to new URL without query and fragment'() {
  given:
    def urlString = 'http://user:pass@localhost:1234/api;bd/v2;a=2/posts?qn=new;dfsadf;asdfsd#sfdf;bdsf'
    def url = new URL(urlString)
  when:
    def url2 = new URL(url.getProtocol() + '://' + url.getAuthority() + url.getPath())
  then:
    url.getProtocol() == 'http'
    url.getAuthority() == 'user:pass@localhost:1234'
    url.getPath() == '/api;bd/v2;a=2/posts'
    url.getQuery() == 'qn=new;dfsadf;asdfsd'
    url.getRef() == 'sfdf;bdsf'
    url.toString().startsWith(url2.toString())
  }
}
