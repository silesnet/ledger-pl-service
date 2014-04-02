package net.snet.ledger.service;

import com.sun.jersey.api.client.Client;

/**
 * Created by admin on 2.4.14.
 */
public class LoadServiceFactory {

	private final Client httpClient;
	private final BatchFactory batchFactory;

	public LoadServiceFactory(Client httpClient, BatchFactory batchFactory) {
		this.httpClient = httpClient;
		this.batchFactory = batchFactory;
	}

	public LoadService newLoadService(InsertGtLoaderFactory.Type type, String pollUrl) {
		final DefaultResource resource = new DefaultResource(httpClient, pollUrl);
		final InsertGtLoaderFactory loaderFactory = new InsertGtLoaderFactory(type);
		return new LoadService(resource, batchFactory, loaderFactory);
	}
}
