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
	private JerseyClientConfiguration httpClient = new JerseyClientConfiguration();

	@Valid
	@JsonProperty
	private long invoicePollDelay = 30;

	@Valid
	@JsonProperty
	@NotNull
	private String invoicePollUrl;

	@Valid
	@JsonProperty
	private long customerPollDelay = 1;

	@Valid
	@JsonProperty
	@NotNull
	private String customerPollUrl;

	public Boolean getJsonPrettyPrint() {
		return jsonPrettyPrint;
	}

	public JerseyClientConfiguration getJerseyClientConfiguration() {
		return httpClient;
	}

	public long getInvoicePollDelay() {
		return invoicePollDelay;
	}

	public String getInvoicePollUrl() {
		return invoicePollUrl;
	}

	public long getCustomerPollDelay() {
		return customerPollDelay;
	}

	public String getCustomerPollUrl() {
		return customerPollUrl;
	}
}
