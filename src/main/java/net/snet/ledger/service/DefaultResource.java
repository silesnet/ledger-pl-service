package net.snet.ledger.service;

import com.google.common.collect.Maps;
import com.sun.jersey.api.client.Client;
import com.sun.jersey.api.client.ClientResponse;
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

	private final WebResource pollResource;
	private final WebResource patchResource;
	private final String name;

	public DefaultResource(Client httpClient, String poll) {
		try {
			URL pollUrl = new URL(poll);
			URL patchUrl =  new URL(pollUrl.getProtocol() + "://" + pollUrl.getAuthority() + pollUrl.getPath());
			pollResource = httpClient.resource(pollUrl.toString());
			patchResource = httpClient.resource(patchUrl.toString());
			name = new File(patchUrl.getPath()).getName();
		} catch (MalformedURLException e) {
			throw new RuntimeException(e);
		}
	}

	@Override
	public List poll() {
		LOGGER.debug("polling for '{}' from '{}'...", name, pollResource.getURI());
		final Map response = pollResource.accept(MediaType.APPLICATION_JSON_TYPE).get(Map.class);
		return (List) response.get(name);
	}

	@Override
	public void patch(List items) {
		LOGGER.debug("patching '{}' at '{}'...", name, pollResource.getURI());
		Map<String, List> patch = Maps.newHashMap();
		patch.put(name, items);
		LOGGER.debug("executing PUT to '{}'", patchResource.getURI());
		ClientResponse response = patchResource
				.accept(MediaType.APPLICATION_JSON_TYPE)
				.type(MediaType.APPLICATION_JSON_TYPE)
				.put(ClientResponse.class, patch);
		if (response.getStatus() != 200) {
			throw new RuntimeException("Failed to patch '" + name + "' resource");
		}
	}
}
