package net.snet.ledger.service;

import com.sun.jersey.api.client.Client;

import java.util.List;

/**
 * Created by admin on 2.4.14.
 */
public class DefaultResource implements RestResource {


	public DefaultResource(Client httpClient, String url) {

	}

	@Override
	public List poll() {
		return null;
	}

	@Override
	public void patch(List items) {

	}
}
