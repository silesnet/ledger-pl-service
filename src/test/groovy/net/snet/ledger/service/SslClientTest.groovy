package net.snet.ledger.service

import com.fasterxml.jackson.databind.ObjectMapper
import com.sun.jersey.api.client.Client
import com.yammer.dropwizard.client.JerseyClientBuilder
import org.apache.http.conn.scheme.PlainSocketFactory
import org.apache.http.conn.scheme.Scheme
import org.apache.http.conn.scheme.SchemeRegistry
import org.apache.http.conn.ssl.SSLSocketFactory
import org.apache.http.conn.ssl.TrustStrategy
import spock.lang.Ignore
import spock.lang.Specification

import javax.ws.rs.core.MediaType
import java.security.cert.CertificateException
import java.security.cert.X509Certificate
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

/**
 * Created by admin on 18.6.14.
 */
class SslClientTest extends Specification {

	@Ignore
	def 'it should GET JSON via HTTPS'() {
	given:
		ExecutorService executorService = Executors.newSingleThreadExecutor()
		ObjectMapper objectMapper = new ObjectMapper()
		Client client =
				new JerseyClientBuilder()
						.using(executorService, objectMapper)
						.using(schemeRegistry())
						.build();
	when:
		def customers = client.resource("https://sis.silesnet.net:8090/customers?qn=ledger-pl-import")
				.accept(MediaType.APPLICATION_JSON_TYPE)
				.get(Map.class)
	then:
		customers.customers != null
	}

	TrustStrategy trustStrategy() {
		return new TrustStrategy() {
			@Override
			boolean isTrusted(X509Certificate[] chain, String authType) throws CertificateException {
				return true
			}
		}
	}

	SchemeRegistry schemeRegistry() {
		SSLSocketFactory socketFactory = new SSLSocketFactory(trustStrategy(), SSLSocketFactory.ALLOW_ALL_HOSTNAME_VERIFIER)
		SchemeRegistry schemeRegistry = new SchemeRegistry()
		schemeRegistry.register(new Scheme("http", 80, PlainSocketFactory.getSocketFactory()))
		schemeRegistry.register(new Scheme("https", 443, socketFactory))
		return schemeRegistry
	}
}
