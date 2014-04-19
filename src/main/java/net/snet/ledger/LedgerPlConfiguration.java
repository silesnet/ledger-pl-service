package net.snet.ledger;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.yammer.dropwizard.client.JerseyClientConfiguration;
import com.yammer.dropwizard.config.Configuration;
import com.yammer.dropwizard.config.LoggingConfiguration;

import javax.validation.Valid;
import javax.validation.constraints.NotNull;
import java.io.File;
import java.io.IOException;
import java.util.Map;

public class LedgerPlConfiguration extends Configuration {
	@Valid
	@JsonProperty
	private File appHome;

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

	@Valid
	@JsonProperty
	private File invoiceBatchPrefix = new File("work/invoice-pl-load-");

	@Valid
	@JsonProperty
	private File customerBatchPrefix = new File("work/customer-pl-load-");

	@Valid
	@JsonProperty
	@NotNull
	private File insertGtConfig;

	@Valid
	@JsonProperty
	@NotNull
	private File loadInvoiceCmd;

	@Valid
	@JsonProperty
	@NotNull
	private File loadCustomerCmd;

	@Valid
	@JsonProperty
	@NotNull
	private Map<Integer, Integer> insertVatMap;

	@Valid
	@JsonProperty
	@NotNull
	private String accountantName;

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

	public File getInvoiceBatchPrefix() {
		return new File(appHome, invoiceBatchPrefix.toString());
	}

	public File getCustomerBatchPrefix() {
		return new File(appHome, customerBatchPrefix.toString());
	}

	public File getInsertGtConfig() {
		return new File(appHome, insertGtConfig.toString());
	}

	public File getLoadInvoiceCmd() {
		return new File(appHome, loadInvoiceCmd.toString());
	}

	public File getLoadCustomerCmd() {
		return new File(appHome, loadCustomerCmd.toString());
	}

	public Map<Integer, Integer> getInsertVatMap() {
		return insertVatMap;
	}

	public String getAccountantName() {
		return accountantName;
	}

	public File getAppHome() {
		try {
			return appHome.getCanonicalFile();
		} catch (IOException e) {
			throw new RuntimeException(e);
		}
	}

	@Override
	public LoggingConfiguration getLoggingConfiguration() {
		final LoggingConfiguration configuration = super.getLoggingConfiguration();
		final LoggingConfiguration.FileConfiguration fc = configuration.getFileConfiguration();
		if (fc != null) {
			fc.setCurrentLogFilename(new File(appHome, fc.getCurrentLogFilename()).getAbsolutePath());
			if (fc.isArchive()) {
				fc.setArchivedLogFilenamePattern(new File(appHome, fc.getArchivedLogFilenamePattern()).getAbsolutePath());
			}
		}
		return configuration;
	}
}
