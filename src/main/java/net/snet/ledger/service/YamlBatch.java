package net.snet.ledger.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.google.common.base.Optional;

import java.io.*;

public class YamlBatch implements Batch {

	private final File file;
	private boolean isReady = false;
	private final YamlDumper dumper;
	private final OutputStream os;

	public YamlBatch(File file) {
		this.file = file;
		dumper = new YamlDumper();
		try {
			os = new BufferedOutputStream(new FileOutputStream(file));
		} catch (FileNotFoundException e) {
			throw new RuntimeException(e);
		}
	}


	@Override
	public File file() {
		return file;
	}

	@Override
	public void header(Optional header) {
		if (header.isPresent()) {
			appendRaw(header.get());
		}
	}

	@Override
	public void append(Object item) {
		try {
			os.write(yamlBytes(item));
		} catch (IOException e) {
			throw new RuntimeException(e);
		}	}

	@Override
	public void trailer(Optional trailer) {
		if (trailer.isPresent()) {
			appendRaw(trailer.get());
		}
		appendRaw("...");
		try {
			os.close();
		} catch (IOException e) {
			throw new RuntimeException(e);
		}
		isReady = true;
	}

	@Override
	public boolean isReady() {
		return isReady;
	}

	private void appendRaw(Object obj) {
		try {
			os.write((obj.toString() + "\n").getBytes());
		} catch (IOException e) {
			throw new RuntimeException(e);
		}
	}

	private byte[] yamlBytes(Object obj) throws JsonProcessingException {
		return dumper.dump(obj).getBytes();
	}

}
