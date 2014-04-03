package net.snet.ledger.service;

import org.joda.time.DateTime;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.File;

/**
 * Created by admin on 2.4.14.
 */
public class YamlBatchFactory implements BatchFactory {
	private static final Logger LOGGER = LoggerFactory.getLogger(YamlBatchFactory.class);

	private final File folder;
	private final String prefix;

	public YamlBatchFactory(File batchPrefix) {
		folder = batchPrefix.getParentFile().getAbsoluteFile();
		if (!folder.exists()) {
			LOGGER.debug("creating working folder '{}'", folder.getPath());
			folder.mkdirs();
		}
		prefix = batchPrefix.getName();
	}

	@Override
	public Batch newBatch() {
		String name = batchName();
		LOGGER.debug("creating new YAML batch '{}'", name);
		return new YamlBatch(new File(folder, name));
	}

	private String batchName() {
		return prefix + timestamp() + ".yml";
	}

	private String timestamp() {
		return new DateTime().toString("yyyyMMdd_HHmmss");
	}

}
