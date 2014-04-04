package net.snet.ledger.service;

import java.io.File;

/**
 * Created by admin on 2.4.14.
 */
public class InsertGtLoaderFactory implements LoaderFactory {

	private final File loadCmd;

	private final File insertGtConfig;

	public InsertGtLoaderFactory(File loadCmd, File insertGtConfig) {
		this.insertGtConfig = insertGtConfig;
		this.loadCmd = loadCmd;
	}

	@Override
	public Loader newLoader() {
		return new InsertGtLoader(loadCmd, insertGtConfig);
	}
}
