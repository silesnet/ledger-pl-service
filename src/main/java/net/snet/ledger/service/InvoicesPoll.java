package net.snet.ledger.service;

import com.sun.jersey.api.client.Client;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Created by admin on 1.4.14.
 */
public class InvoicesPoll implements Runnable {
	private static final Logger LOGGER = LoggerFactory.getLogger(InvoicesPoll.class);

	private final Client httpClient;

	public InvoicesPoll(Client httpClient) {
		this.httpClient = httpClient;
	}

	@Override
	public void run() {
		LOGGER.info("Polling for invoices...");
	}
}
