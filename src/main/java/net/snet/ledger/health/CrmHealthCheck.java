package net.snet.ledger.health;

import com.codahale.metrics.health.HealthCheck;
import com.sun.jersey.api.client.Client;

import java.net.URI;

/**
 * Created by admin on 21.6.14.
 */
public class CrmHealthCheck extends HealthCheck {

	private final Client httpClient;
	private final URI crmUri;

	public CrmHealthCheck(Client httpClient, URI crmUri) {
		super();
		this.httpClient = httpClient;
		this.crmUri = crmUri;
	}

	@Override
	protected HealthCheck.Result check() throws Exception {
		final String pong = httpClient.resource(crmUri).get(String.class);
		if (null != pong) {
			return Result.healthy();
		} else {
			return Result.unhealthy("Cannot reach CRM service at '%s'.", crmUri.toString());
		}
	}
}
