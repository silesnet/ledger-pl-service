package net.snet.ledger.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.dataformat.yaml.YAMLFactory;
import com.sun.jersey.api.client.Client;
import com.sun.jersey.api.client.WebResource;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.ws.rs.core.MediaType;
import java.util.List;
import java.util.Map;

/**
 * Created by admin on 1.4.14.
 */
public class InvoicesPoll implements Runnable {
	private static final Logger LOGGER = LoggerFactory.getLogger(InvoicesPoll.class);

	private final String ledgerPlLoadUrl;
	private final WebResource invoicesResource;


	public InvoicesPoll(Client httpClient, String ledgerPlLoadUrl) {
		this.ledgerPlLoadUrl = ledgerPlLoadUrl;
		invoicesResource = httpClient.resource(ledgerPlLoadUrl);
	}

	@Override
	public void run() {
		LOGGER.info("polling for invoices from '{}'...", ledgerPlLoadUrl);
		try {
			final Map invoicesResponse = invoicesResource.accept(MediaType.APPLICATION_JSON_TYPE).get(Map.class);
			final List<Map> invoices = (List<Map>) invoicesResponse.get("invoices");

			ObjectMapper mapper = new ObjectMapper(new YAMLFactory());

			for (Map invoice : invoices) {
				LOGGER.info("got invoice '{}'", invoice.get("number").toString());
				LOGGER.info(mapper.writeValueAsString(invoice));
			}
		} catch (Exception e) {
			LOGGER.error("FAILED polling for invoices", e);
		}
	}
}
