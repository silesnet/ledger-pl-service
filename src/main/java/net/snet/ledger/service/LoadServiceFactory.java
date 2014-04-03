package net.snet.ledger.service;

import com.sun.jersey.api.client.Client;

/**
 * Created by admin on 2.4.14.
 */
public class LoadServiceFactory {

	private final Client httpClient;

	public LoadServiceFactory(Client httpClient) {
		this.httpClient = httpClient;
	}

	public LoadService newLoadService(InsertGtLoaderFactory.Type type, String pollUrl, BatchFactory batchFactory) {
		final RestResource resource = new DefaultResource(httpClient, pollUrl);
		final LoaderFactory loaderFactory = new InsertGtLoaderFactory(type);
		return new LoadService(resource, batchFactory, loaderFactory);
	}
}
