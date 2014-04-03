package net.snet.ledger;

import com.fasterxml.jackson.databind.SerializationFeature;
import com.sun.jersey.api.client.Client;
import com.yammer.dropwizard.Service;
import com.yammer.dropwizard.client.JerseyClientBuilder;
import com.yammer.dropwizard.config.Bootstrap;
import com.yammer.dropwizard.config.Environment;
import net.snet.ledger.resources.LedgerPlResource;
import net.snet.ledger.service.*;

import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

import static net.snet.ledger.service.InsertGtLoaderFactory.Type.*;

public class LedgerPlService extends Service<LedgerPlConfiguration> {
  public static void main(String[] args) throws Exception {
    new LedgerPlService().run(args);
  }

  @Override
  public void initialize(Bootstrap<LedgerPlConfiguration> bootstrap) {
    bootstrap.setName("ledger-pl-service");
  }

  @Override
  public void run(LedgerPlConfiguration conf, Environment env) throws ClassNotFoundException {

		final Client httpClient = new JerseyClientBuilder()
				.using(conf.getJerseyClientConfiguration())
				.using(env)
				.build();
		final LoadServiceFactory loadServiceFactory = new LoadServiceFactory(httpClient);

		final ScheduledExecutorService executorService = env.managedScheduledExecutorService("loader", 2);

	  final BatchFactory invoiceBatchFactory = new YamlBatchFactory(conf.getInvoiceBatchPrefix());
		final LoadService loadInvoices = loadServiceFactory.newLoadService(INVOICE, conf.getInvoicePollUrl(), invoiceBatchFactory);
		executorService.scheduleWithFixedDelay(loadInvoices, 0, conf.getInvoicePollDelay(), TimeUnit.MILLISECONDS);

	  final BatchFactory customerBatchFactory = new YamlBatchFactory(conf.getCustomerBatchPrefix());
		final LoadService loadCustomers = loadServiceFactory.newLoadService(CUSTOMER, conf.getCustomerPollUrl(), customerBatchFactory);
		executorService.scheduleWithFixedDelay(loadCustomers, 0, conf.getCustomerPollDelay(), TimeUnit.MILLISECONDS);

		if (conf.getJsonPrettyPrint()) {
			env.getObjectMapperFactory().enable(SerializationFeature.INDENT_OUTPUT);
		}
		env.addResource(new LedgerPlResource());
	}

}
