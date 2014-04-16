package net.snet.ledger;

import com.fasterxml.jackson.databind.SerializationFeature;
import com.sun.jersey.api.client.Client;
import com.yammer.dropwizard.Service;
import com.yammer.dropwizard.client.JerseyClientBuilder;
import com.yammer.dropwizard.config.Bootstrap;
import com.yammer.dropwizard.config.Environment;
import net.snet.ledger.resources.LedgerPlResource;
import net.snet.ledger.service.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Properties;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

public class LedgerPlService extends Service<LedgerPlConfiguration> {
	private static final Logger LOGGER = LoggerFactory.getLogger(LedgerPlService.class);

  public static void main(String[] args) throws Exception {
    new LedgerPlService().run(args);
  }

  @Override
  public void initialize(Bootstrap<LedgerPlConfiguration> bootstrap) {
    bootstrap.setName("ledger-pl-service");
  }

  @Override
  public void run(LedgerPlConfiguration conf, Environment env) throws ClassNotFoundException {
		LOGGER.debug("Application home '{}'", conf.getAppHome());

		final Client httpClient =
				new JerseyClientBuilder()
					.using(conf.getJerseyClientConfiguration())
					.using(env)
					.build();
		final LoadServiceFactory loadServiceFactory = new LoadServiceFactory(httpClient, conf.getInsertGtConfig());

		final ScheduledExecutorService executorService = env.managedScheduledExecutorService("loader", 2);

		final LoadServiceConfig loadInvoicesConfig =
				new LoadServiceConfig.Builder()
					.withPollUrl(conf.getInvoicePollUrl())
					.withMapper(new InvoiceMapper(conf.getInsertVatMap(), conf.getAccountantName()))
					.withBatchFactory(new YamlBatchFactory(conf.getInvoiceBatchPrefix()))
					.withLoadCommand(conf.getLoadInvoiceCmd())
					.build();
		final LoadService loadInvoices = loadServiceFactory.newLoadService(loadInvoicesConfig);
		executorService.scheduleWithFixedDelay(loadInvoices, 0, conf.getInvoicePollDelay(), TimeUnit.MILLISECONDS);

//		final LoadServiceConfig loadCustomersConfig = new LoadServiceConfig.Builder()
//				.withPollUrl(conf.getCustomerPollUrl())
//				.withMapper(new CustomerMapper())
//				.withBatchFactory(new YamlBatchFactory(conf.getCustomerBatchPrefix()))
//				.withLoadCommand(conf.getLoadCustomerCmd())
//				.build();
//		final LoadService loadCustomers = loadServiceFactory.newLoadService(loadCustomersConfig);
//		executorService.scheduleWithFixedDelay(loadCustomers, 0, conf.getCustomerPollDelay(), TimeUnit.MILLISECONDS);

		if (conf.getJsonPrettyPrint()) {
			env.getObjectMapperFactory().enable(SerializationFeature.INDENT_OUTPUT);
		}
		env.addResource(new LedgerPlResource());
	}

}
