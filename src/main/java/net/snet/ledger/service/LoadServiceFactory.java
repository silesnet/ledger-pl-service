package net.snet.ledger.service;

import com.sun.jersey.api.client.Client;

import java.io.File;

/**
 * Created by admin on 2.4.14.
 */
public class LoadServiceFactory {

	private final Client httpClient;
	private final File insertGtConfig;

	public LoadServiceFactory(Client httpClient, File insertGtConfig) {
		this.httpClient = httpClient;
		this.insertGtConfig = insertGtConfig;
	}

	public LoadService newLoadService(LoadServiceConfig config) {
		final RestResource resource = new DefaultResource(httpClient, config.pollUrl());
		final LoaderFactory loaderFactory = new InsertGtLoaderFactory(config.loadCommand(), insertGtConfig);
		return new LoadService(resource, config.batchFactory(), loaderFactory, config.mapper());
	}
}
