package net.snet.ledger.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.dataformat.yaml.snakeyaml.DumperOptions;
import com.fasterxml.jackson.dataformat.yaml.snakeyaml.Yaml;
import com.google.common.base.Optional;

import java.io.*;

public class YamlBatch implements Batch {

	public static final int YAML_LINE_WIDTH = 1024;

	private final File file;
	private boolean isReady = false;
	private final Yaml yaml;
	private final OutputStream os;

	public YamlBatch(File file) {
		this.file = file;
		yaml = new Yaml(yamlOptions());
		try {
			os = new BufferedOutputStream(new FileOutputStream(file));
		} catch (FileNotFoundException e) {
			throw new RuntimeException(e);
		}
	}

	private DumperOptions yamlOptions() {
		final DumperOptions options = new DumperOptions();
		options.setCanonical(false);
		options.setDefaultFlowStyle(DumperOptions.FlowStyle.BLOCK);
		options.setExplicitStart(true);
		options.setExplicitEnd(false);
		options.setWidth(YAML_LINE_WIDTH);
		return options;
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
		return yaml.dump(obj).getBytes();
	}

}
