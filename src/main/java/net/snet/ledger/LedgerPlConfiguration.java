package net.snet.ledger;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.yammer.dropwizard.client.JerseyClientConfiguration;
import com.yammer.dropwizard.config.Configuration;

import javax.validation.Valid;
import javax.validation.constraints.NotNull;

public class LedgerPlConfiguration extends Configuration {

	@Valid
	@JsonProperty
	private Boolean jsonPrettyPrint = false;

	@Valid
	@JsonProperty
	private long invoicesPollingDelay = 5;

	@Valid
	@JsonProperty
	private JerseyClientConfiguration httpClient = new JerseyClientConfiguration();

	@Valid
	@JsonProperty
	@NotNull
	private String ledgerPlLoadUrl;

	public Boolean getJsonPrettyPrint() {
		return jsonPrettyPrint;
	}

	public long getInvoicesPollingDelay() {
		return invoicesPollingDelay;
	}

	public JerseyClientConfiguration getJerseyClientConfiguration() {
		return httpClient;
	}

	public String getLedgerPlLoadUrl() {
		return ledgerPlLoadUrl;
	}
}
