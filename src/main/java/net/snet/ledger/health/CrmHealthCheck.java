package net.snet.ledger.health;

import com.sun.jersey.api.client.Client;
import com.yammer.metrics.core.HealthCheck;

import java.net.URI;

/**
 * Created by admin on 21.6.14.
 */
public class CrmHealthCheck extends HealthCheck {

	private final Client httpClient;
	private final URI crmUri;

	public CrmHealthCheck(String name, Client httpClient, URI crmUri) {
		super(name);
		this.httpClient = httpClient;
		this.crmUri = crmUri;
	}

	@Override
	protected Result check() throws Exception {
		final String pong = httpClient.resource(crmUri).get(String.class);
		if (null != pong) {
			return Result.healthy();
		} else {
			return Result.unhealthy("Cannot reach CRM service at '%s'.", crmUri.toString());
		}
	}
}
