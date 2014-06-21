package net.snet.ledger.health;

import com.sun.jersey.api.client.Client;
import com.yammer.metrics.core.HealthCheck;

import java.net.URI;

public class AccountantHealthCheck extends HealthCheck {

	private final Client httpClient;
	private final URI accountantUri;

	public AccountantHealthCheck(String name, Client httpClient, URI accountantUri) {
		super(name);
		this.httpClient = httpClient;
		this.accountantUri = accountantUri;
	}

	@Override
	protected Result check() throws Exception {
		final String pong = httpClient.resource(accountantUri).get(String.class);
		if (null != pong) {
			return Result.healthy();
		} else {
			return Result.unhealthy("Cannot reach accountant service at '%s'.", accountantUri.toString());
		}
	}
}
