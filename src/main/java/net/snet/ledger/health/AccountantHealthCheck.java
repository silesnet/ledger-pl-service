package net.snet.ledger.health;

import com.codahale.metrics.health.HealthCheck;
import com.sun.jersey.api.client.Client;

import java.net.URI;

public class AccountantHealthCheck extends HealthCheck {

	private final Client httpClient;
	private final URI accountantUri;

	public AccountantHealthCheck(Client httpClient, URI accountantUri) {
		super();
		this.httpClient = httpClient;
		this.accountantUri = accountantUri;
	}

	@Override
	protected HealthCheck.Result check() throws Exception {
		final String pong = httpClient.resource(accountantUri).get(String.class);
		if (null != pong) {
			return Result.healthy();
		} else {
			return Result.unhealthy("Cannot reach accountant service at '%s'.", accountantUri.toString());
		}
	}
}
