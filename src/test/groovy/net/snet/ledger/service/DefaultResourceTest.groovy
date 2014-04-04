package net.snet.ledger.service

import com.sun.jersey.api.client.Client
import com.sun.net.httpserver.HttpExchange
import com.sun.net.httpserver.HttpHandler
import com.sun.net.httpserver.HttpServer
import spock.lang.Specification

/**
 * Created by admin on 4.4.14.
 */
class DefaultResourceTest extends Specification {
	HttpServer server
  def changes = null

	def setup() {
    changes = null
		server = HttpServer.create(new InetSocketAddress(8098), 0)
		server.createContext("/items", new HttpHandler() {
			@Override
			void handle(HttpExchange httpExchange) throws IOException {
        if (httpExchange.getRequestMethod() == 'PUT') {
          changes = httpExchange.getRequestBody().text
          println changes
          httpExchange.sendResponseHeaders(200, 0);
        } else if (httpExchange.getRequestMethod() == 'GET') {
          def res = '''\n
{
	"items": [
		{ "name": "Item 1" }
	]
}
'''
          def headers = httpExchange.getResponseHeaders()
          headers.'Content-Type' = 'application/json'
          httpExchange.sendResponseHeaders(200, res.length())
          def os = httpExchange.getResponseBody()
          os.write(res.getBytes())
          os.close()
        } else {
          httpExchange.sendResponseHeaders(300, 0);
        }
      }
		})
		server.setExecutor(null)
		server.start()
	}

	def cleanup() {
		server.stop(0)
	}

	def 'it should poll for items'() {
	given:
		def url = 'http://localhost:8098/items?qn=all'
		def client = Client.create()
		def resource = new DefaultResource(client, url)
	when:
		def items = resource.poll()
	then:
		items.size() > 0
		items[0].name == 'Item 1'
	}

	def 'it should get resource name from url'() {
		def url = new URL('http://localhost:1234/api/v2/posts?qn=new')
		def name = new File(url.getPath()).getName()
	expect:
		name == 'posts'
	}

  def 'it should put item updates to url'() {
  given:
    def url = 'http://localhost:8098/items?qn=all'
    def client = Client.create()
    def resource = new DefaultResource(client, url)
    def patches = [ [id: 1, 'synchronized': '2014-04-04T10:20:30.123'], [id: 2, 'synchronized': '2014-04-04T10:20:30.123']]
  when:
    resource.patch(patches)
  then:
    changes != null
  }

}
