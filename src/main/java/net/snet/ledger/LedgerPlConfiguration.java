package net.snet.ledger;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.yammer.dropwizard.client.JerseyClientConfiguration;
import com.yammer.dropwizard.config.Configuration;
import com.yammer.dropwizard.config.LoggingConfiguration;
import com.yammer.dropwizard.util.Duration;

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
	private Duration invoicePollDelay = Duration.minutes(10);

	@Valid
	@JsonProperty
	@NotNull
	private String invoicePollUrl;

	@Valid
	@JsonProperty
	private Duration customerPollDelay = Duration.seconds(5);

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

	public Duration getInvoicePollDelay() {
		return invoicePollDelay;
	}

	public String getInvoicePollUrl() {
		return invoicePollUrl;
	}

	public Duration getCustomerPollDelay() {
		return customerPollDelay;
	}

	public String getCustomerPollUrl() {
		return customerPollUrl;
	}

	public File getInvoiceBatchPrefix() {
		return path(invoiceBatchPrefix);
	}

	public File getCustomerBatchPrefix() {
		return path(customerBatchPrefix);
	}

	public File getInsertGtConfig() {
		return path(insertGtConfig);
	}

	public File getLoadInvoiceCmd() {
		return path(loadInvoiceCmd);
	}

	public File getLoadCustomerCmd() {
		return path(loadCustomerCmd);
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
			fc.setCurrentLogFilename(path(fc.getCurrentLogFilename()).toString());
			if (fc.isArchive()) {
				fc.setArchivedLogFilenamePattern(path(fc.getArchivedLogFilenamePattern()).toString());
			}
		}
		return configuration;
	}

	private File path(String path) {
		return path(new File(path));
	}

	private File path(File file) {
		File result = file;
		if (!file.isAbsolute()) {
			result = new File(appHome, file.getPath());
		}
		try {
			return result.getCanonicalFile();
		} catch (IOException e) {
			throw new RuntimeException(e);
		}
	}
}
