package net.snet.ledger.service;

import com.google.common.base.Optional;
import com.google.common.collect.Lists;
import com.google.common.collect.Maps;
import org.joda.time.DateTime;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.List;
import java.util.Map;

/**
 * Created by admin on 1.4.14.
 */
public class LoadService implements Runnable {
	private static final Logger LOGGER = LoggerFactory.getLogger(LoadService.class);

	private final RestResource restResource;
	private final BatchFactory batchFactory;
	private final LoaderFactory loaderFactory;
	private final Mapper mapper;

	public LoadService(RestResource restResource, BatchFactory batchFactory, LoaderFactory loaderFactory, Mapper mapper) {
		this.restResource = restResource;
		this.batchFactory = batchFactory;
		this.loaderFactory = loaderFactory;
		this.mapper = mapper;
	}

	@Override
	public void run() {
		try {
			LOGGER.info("load STARTED...");
			LOGGER.info("polling...");
			final List items = restResource.poll();

			LOGGER.info("creating batch...");
			final Batch batch = batchFactory.newBatch();
			for (Object item : items) {
				batch.append(mapper.map((Map) item));
			}
			batch.trailer(Optional.absent());

			LOGGER.info("loading batch...");
			final Loader loader = loaderFactory.newLoader();
			final Journal journal = loader.load(batch.file());

			LOGGER.info("processing load journal...");
			final DateTime now = new DateTime();
			final List<Map> invoices = Lists.newArrayList();
			while (journal.hasNext()) {
				final Record record = journal.next();
				if (record.isOk()) {
					LOGGER.info("loaded '{}'", record.id());
					final Map<String, Object> patch = Maps.newHashMap();
					patch.put("id", record.id());
					patch.put("synchronized", now);
					invoices.add(patch);
				} else {
					LOGGER.error(record.message());
				}
			}
			if (invoices.size() > 0) {
				LOGGER.info("patching resources...");
				restResource.patch(invoices);
			} else {
				LOGGER.info("no invoices were loaded, patching skipped");
			}
			LOGGER.info("FINISHED load");
		} catch (Exception e) {
			LOGGER.error("FAILED load", e);
		}
	}
}
