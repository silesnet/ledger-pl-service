package net.snet.ledger;

import com.fasterxml.jackson.databind.SerializationFeature;
import com.sun.jersey.api.client.Client;
import com.yammer.dropwizard.Service;
import com.yammer.dropwizard.client.JerseyClientBuilder;
import com.yammer.dropwizard.config.Bootstrap;
import com.yammer.dropwizard.config.Environment;
import net.snet.ledger.resources.LedgerPlResource;
import net.snet.ledger.service.InvoicesPoll;

import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

public class LedgerPlService extends Service<LedgerPlConfiguration> {
  public static void main(String[] args) throws Exception {
    new LedgerPlService().run(args);
  }

  @Override
  public void initialize(Bootstrap<LedgerPlConfiguration> bootstrap) {
    bootstrap.setName("ledger-pl-service");
  }

  @Override
  public void run(LedgerPlConfiguration configuration, Environment environment) throws ClassNotFoundException {

		final Client httpClient = new JerseyClientBuilder().using(configuration.getJerseyClientConfiguration())
				.using(environment)
				.build();

		final ScheduledExecutorService executorService = environment.managedScheduledExecutorService("poll-invoices", 1);
		final InvoicesPoll invoicesPoll = new InvoicesPoll(httpClient);
		executorService.scheduleWithFixedDelay(invoicesPoll, 0, configuration.getInvoicesPollingDelay(), TimeUnit.SECONDS);

		if (configuration.getJsonPrettyPrint()) {
			environment.getObjectMapperFactory().enable(SerializationFeature.INDENT_OUTPUT);
		}
		environment.addResource(new LedgerPlResource());
	}

}
