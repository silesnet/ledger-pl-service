package net.snet.ledger.service;

import com.google.common.base.Optional;
import com.google.common.collect.Lists;
import com.google.common.collect.Maps;
import org.joda.time.DateTime;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.List;
import java.util.Map;

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
			LOGGER.debug("load {} STARTED...", restResource.name());
			LOGGER.debug("polling for {}...", restResource.name());
			final List items = restResource.poll();
			if (items.size() > 0) {
				LOGGER.info("{} {} items found", items.size(), restResource.name());
				LOGGER.info("creating {} batch...", restResource.name());
				final Batch batch = batchFactory.newBatch();
				for (Object item : items) {
					batch.append(mapper.map((Map) item));
				}
				batch.trailer(Optional.absent());

				LOGGER.info("loading {} batch...", restResource.name());
				final Loader loader = loaderFactory.newLoader();
				final Journal journal = loader.load(batch.file());

				LOGGER.info("processing {} load journal...", restResource.name());
				final String now = new DateTime().toString();
				final List<Map> updates = Lists.newArrayList();
				int loaded = 0;
				while (journal.hasNext()) {
					final Record record = journal.next();
					final Map<String, Object> patch = Maps.newHashMap();
					patch.put("id", record.id());
					if (record.isOk()) {
						LOGGER.info("loaded {}: '{}'", restResource.name(), record.id());
						loaded++;
						patch.put("synchronized", now);
					} else {
						LOGGER.info("failed to load {}: '{}'", restResource.name(), record.id());
						LOGGER.error(record.message());
						patch.put("synchronized", null);
					}
					updates.add(patch);
				}
				if (updates.size() > 0) {
					LOGGER.info("patching {} resources...", restResource.name());
					restResource.patch(updates);
				} else {
					LOGGER.info("no {} items were loaded, patching skipped", restResource.name());
				}
				LOGGER.info("loaded {} of {} {}", loaded, items.size(), restResource.name());
			} else {
				LOGGER.debug("no {} items found", restResource.name());
			}
			LOGGER.debug("FINISHED load {}", restResource.name());
		} catch (Exception e) {
			LOGGER.error("FAILED load " + restResource.name(), e);
		}
	}
}
