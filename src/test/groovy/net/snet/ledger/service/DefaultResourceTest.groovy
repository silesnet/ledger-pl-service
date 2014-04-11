package net.snet.ledger.service

import com.sun.jersey.api.client.Client
import com.sun.net.httpserver.HttpExchange
import com.sun.net.httpserver.HttpHandler
import com.sun.net.httpserver.HttpServer
import groovy.json.JsonSlurper
import org.slf4j.LoggerFactory
import spock.lang.Ignore
import spock.lang.Shared
import spock.lang.Specification

/**
 * Created by admin on 4.4.14.
 */
class DefaultResourceTest extends Specification {
  def static final LOGGER = LoggerFactory.getLogger(DefaultResourceTest.class)
  def @Shared server
  def @Shared handler = new TestHttpHandler()

	def setupSpec() {
		server = HttpServer.create(new InetSocketAddress(8098), 0)
		server.createContext("/items", handler)
		server.setExecutor(null)
		server.start()
    LOGGER.debug "HTTP test server started..."
	}

	def cleanupSpec() {
		server.stop(0)
    LOGGER.debug "HTTP test server stopped"
	}

	def 'it should poll for items'() {
	given:
		def url = 'http://localhost:8098/items?qn=all'
		def client = Client.create()
		def resource = new DefaultResource(client, url)
    handler.clearLastRequest()
	when:
		def items = resource.poll()
    def uri = handler.lastRequest().uri as URI
	then:
    uri.getQuery() == 'qn=all'
		items.size() > 0
		items[0].name == 'Item 1'
	}

	def 'it should put item updates to url'() {
  given:
    def url = 'http://localhost:8098/items?qn=all'
    def client = Client.create()
    def resource = new DefaultResource(client, url)
    def patches = [ [id: 1, 'synchronized': '2014-04-04T10:20:30.123'], [id: 2, 'synchronized': '2014-04-04T10:20:30.123']]
    handler.clearLastRequest()
  when:
    resource.patch(patches)
    def changes = new JsonSlurper().parseText(handler.lastRequest().body as String) as Map
    def uri = handler.lastRequest().uri as URI
  then:
    uri.getQuery() == null
    changes.items.get(0).id == 1
    changes.items.get(1).id == 2
  }


  static class TestHttpHandler implements HttpHandler {

    Map request = [:]

    @Override
    void handle(HttpExchange httpExchange) throws IOException {
      request.uri = httpExchange.getRequestURI();
      if (httpExchange.getRequestMethod() == 'PUT') {
        request.body = httpExchange.getRequestBody().text
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
        httpExchange.sendResponseHeaders(405, 0);
      }
    }

    Map lastRequest() {
      return request;
    }

    void clearLastRequest() {
      request = [:]
    }
  }

}
