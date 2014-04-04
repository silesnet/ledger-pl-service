package net.snet.ledger.service;

import com.sun.jersey.api.client.Client;
import com.sun.jersey.api.client.WebResource;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.ws.rs.core.MediaType;
import java.io.File;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.List;
import java.util.Map;

/**
 * Created by admin on 2.4.14.
 */
public class DefaultResource implements RestResource {
	private static final Logger LOGGER = LoggerFactory.getLogger(DefaultResource.class);

	private final WebResource resource;
	private final URL url;
	private final String name;

	public DefaultResource(Client httpClient, String url) {
		try {
			this.url = new URL(url);
			name = new File(this.url.getPath()).getName();
		} catch (MalformedURLException e) {
			throw new RuntimeException(e);
		}
		this.resource = httpClient.resource(url);
	}

	@Override
	public List poll() {
		LOGGER.debug("polling for '{}' from '{}'..", name, url);
		final Map response = resource.accept(MediaType.APPLICATION_JSON_TYPE).get(Map.class);
		return (List) response.get(name);
	}

	@Override
	public void patch(List items) {

	}
}
