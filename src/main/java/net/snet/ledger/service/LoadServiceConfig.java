package net.snet.ledger.service;

import com.google.common.base.Preconditions;

import java.io.File;

import static com.google.common.base.Preconditions.checkNotNull;

/**
 * Created by admin on 7.4.14.
 */
public class LoadServiceConfig {
	private final String pollUrl;
	private final Mapper mapper;
	private final BatchFactory batchFactory;
	private final File loadCommand;

	private LoadServiceConfig(String pollUrl, Mapper mapper, BatchFactory batchFactory, File loadCommand) {
		checkNotNull(pollUrl, "poll url cannot be null");
		checkNotNull(mapper, "mapper cannot be null");
		checkNotNull(batchFactory, "batch factory cannot be null");
		checkNotNull(loadCommand, "load command cannot be null");
		this.pollUrl = pollUrl;
		this.mapper = mapper;
		this.batchFactory = batchFactory;
		this.loadCommand = loadCommand;
	}

	public String pollUrl() {
		return pollUrl;
	}

	public Mapper mapper() {
		return mapper;
	}

	public BatchFactory batchFactory() {
		return batchFactory;
	}

	public File loadCommand() {
		return loadCommand;
	}

	public static class Builder {
		private String pollUrl;
		private Mapper mapper;
		private BatchFactory batchFactory;
		private File loadCommand;

		public LoadServiceConfig build() {
			return new LoadServiceConfig(pollUrl, mapper, batchFactory, loadCommand);
		}

		public Builder withPollUrl(String pollUrl) {
			this.pollUrl = pollUrl;
			return this;
		}

		public Builder withMapper(Mapper mapper) {
			this.mapper = mapper;
			return this;
		}

		public Builder withBatchFactory(BatchFactory batchFactory) {
			this.batchFactory = batchFactory;
			return this;
		}

		public Builder withLoadCommand(File loadCommand) {
			this.loadCommand = loadCommand;
			return this;
		}
	}
}
