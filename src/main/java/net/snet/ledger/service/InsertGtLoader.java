package net.snet.ledger.service;

import com.google.common.base.Joiner;
import com.google.common.base.Strings;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;

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
			final ProcessBuilder builder = new ProcessBuilder(cmd);
			builder.redirectErrorStream(true);
			Process process = builder.start();
			status = process.waitFor();
			BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()));
			String line;
			while ((line = reader.readLine()) != null) {
				line = line.trim();
				if (!Strings.isNullOrEmpty(line)) {
					LOGGER.debug(line);
				}
			}
		} catch (InterruptedException e) {
			throw new RuntimeException(e);
		} catch (IOException e) {
			throw new RuntimeException(e);
		}
		if (status == 0) {
			LOGGER.error("FAILED loading into InsERT GT with error code '{}'", status);
			throw new RuntimeException("FAILED loading into InsERT GT with error code '" + status + "'");
		}
		return new CsvJournal(journalFile(file));
	}

	private File journalFile(File file) {
		return new File(file.getParentFile(), file.getName() + ".jrn");
	}
}
