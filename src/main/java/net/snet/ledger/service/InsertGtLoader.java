package net.snet.ledger.service;

import com.google.common.base.Joiner;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;

/**
 * Created by admin on 2.4.14.
 */
public class InsertGtLoader implements Loader {
	private static final Logger LOGGER = LoggerFactory.getLogger(InsertGtLoader.class);

	private final File insertGtConfig;
	private final File loadCmd;

	public InsertGtLoader(File loadCmd, File insertGtConfig) {
		this.loadCmd = loadCmd;
		this.insertGtConfig = insertGtConfig;
	}

	@Override
	public Journal load(final File file) {
		LOGGER.info("loading '{}' into InsERT GT...", file);
		String[] cmd = {loadCmd.getPath(), file.getPath(), insertGtConfig.getPath()};
		LOGGER.debug("executing '{}'", Joiner.on(" ").join(cmd));
		int status;
		try {
			Process process = Runtime.getRuntime().exec(cmd);
			status = process.waitFor();
			BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()));
			String line;
			while ((line = reader.readLine()) != null) {
				LOGGER.debug(line);
			}
		} catch (IOException | InterruptedException e) {
			throw new RuntimeException(e);
		}
		if (status != 0) {
			LOGGER.error("FAILED loading into InsERT GT with error code '{}'", status);
			throw new RuntimeException("FAILED loading into InsERT GT with error code '" + status + "'");
		}
		return new CsvJournal(journalFile(file));
	}

	private File journalFile(File file) {
		return new File(file.getParentFile(), file.getName() + ".jrn");
	}
}
