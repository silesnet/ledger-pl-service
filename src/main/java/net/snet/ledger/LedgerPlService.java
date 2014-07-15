package net.snet.ledger;

import com.fasterxml.jackson.databind.SerializationFeature;
import com.sun.jersey.api.client.Client;
import io.dropwizard.Application;
import io.dropwizard.client.JerseyClientBuilder;
import io.dropwizard.setup.Bootstrap;
import io.dropwizard.setup.Environment;
import io.dropwizard.util.Duration;
import net.snet.ledger.health.AccountantHealthCheck;
import net.snet.ledger.health.CrmHealthCheck;
import net.snet.ledger.resources.LedgerPlResource;
import net.snet.ledger.service.*;
import org.apache.http.conn.scheme.PlainSocketFactory;
import org.apache.http.conn.scheme.Scheme;
import org.apache.http.conn.scheme.SchemeRegistry;
import org.apache.http.conn.ssl.SSLSocketFactory;
import org.apache.http.conn.ssl.TrustStrategy;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.net.URISyntaxException;
import java.security.KeyManagementException;
import java.security.KeyStoreException;
import java.security.NoSuchAlgorithmException;
import java.security.UnrecoverableKeyException;
import java.security.cert.CertificateException;
import java.security.cert.X509Certificate;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

public class LedgerPlService extends Application<LedgerPlConfiguration> {
	private static final Logger LOGGER = LoggerFactory.getLogger(LedgerPlService.class);

  public static void main(String[] args) throws Exception {
    new LedgerPlService().run(args);
  }

  @Override
  public void initialize(Bootstrap<LedgerPlConfiguration> bootstrap) {
  }

  @Override
  public void run(LedgerPlConfiguration conf, Environment env) throws ClassNotFoundException, NoSuchAlgorithmException, UnrecoverableKeyException, KeyStoreException, KeyManagementException, URISyntaxException {
		LOGGER.debug("Application home '{}'", conf.getAppHome());

		final Client httpClient =
				new JerseyClientBuilder(env)
					.using(conf.getJerseyClientConfiguration())
					.using(schemeRegistry())
					.using(env)
					.build("ledger-http-client");
		final LoadServiceFactory loadServiceFactory = new LoadServiceFactory(httpClient, conf.getInsertGtConfig());

	  final ScheduledExecutorService executorService = env.lifecycle().scheduledExecutorService("loader").threads(2).build();

		final LoadServiceConfig loadInvoicesConfig =
				new LoadServiceConfig.Builder()
					.withPollUrl(conf.getInvoicePollUrl())
					.withMapper(new InvoiceMapper(conf.getInsertVatMap(), conf.getAccountantName()))
					.withBatchFactory(new YamlBatchFactory(conf.getInvoiceBatchPrefix()))
					.withLoadCommand(conf.getLoadInvoiceCmd())
					.build();
		final LoadService loadInvoices = loadServiceFactory.newLoadService(loadInvoicesConfig);
		executorService.scheduleWithFixedDelay(loadInvoices, conf.getInvoicePollDelay().toMilliseconds(),
				conf.getInvoicePollDelay().toMilliseconds(), TimeUnit.MILLISECONDS);

		final LoadServiceConfig loadCustomersConfig = new LoadServiceConfig.Builder()
				.withPollUrl(conf.getCustomerPollUrl())
				.withMapper(new CustomerMapper())
				.withBatchFactory(new YamlBatchFactory(conf.getCustomerBatchPrefix()))
				.withLoadCommand(conf.getLoadCustomerCmd())
				.build();
		final LoadService loadCustomers = loadServiceFactory.newLoadService(loadCustomersConfig);
		executorService.scheduleWithFixedDelay(loadCustomers, conf.getCustomerPollDelay().toMilliseconds(),
				conf.getCustomerPollDelay().toMilliseconds(), TimeUnit.MILLISECONDS);

		if (conf.getJsonPrettyPrint()) {
			env.getObjectMapper().enable(SerializationFeature.INDENT_OUTPUT);
		}
		env.jersey().register(new LedgerPlResource());
		env.healthChecks().register("accountant-service", new AccountantHealthCheck(httpClient, conf.getAccountantHealthCheckUri()));
		env.healthChecks().register("crm-service", new CrmHealthCheck(httpClient, conf.getCrmHealthCheckUri()));
	}

	private SchemeRegistry schemeRegistry() throws UnrecoverableKeyException, NoSuchAlgorithmException, KeyStoreException, KeyManagementException {
		SSLSocketFactory socketFactory = new SSLSocketFactory(trustStrategy(), SSLSocketFactory.ALLOW_ALL_HOSTNAME_VERIFIER);
		SchemeRegistry schemeRegistry = new SchemeRegistry();
		schemeRegistry.register(new Scheme("http", 80, PlainSocketFactory.getSocketFactory()));
		schemeRegistry.register(new Scheme("https", 443, socketFactory));
		return schemeRegistry;
	}

	private TrustStrategy trustStrategy() {
		return new TrustStrategy() {
			@Override
			public boolean isTrusted(X509Certificate[] chain, String authType) throws CertificateException {
				return true;
			}
		};
	}

}
