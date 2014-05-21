package net.snet.ledger.service;

import com.fasterxml.jackson.dataformat.yaml.snakeyaml.DumperOptions;
import com.fasterxml.jackson.dataformat.yaml.snakeyaml.Yaml;

/**
 * Created by sikorric on 2014-05-21.
 */
public class YamlDumper {
	private static final int YAML_LINE_WIDTH = 0;
	private final Yaml yaml;

	public YamlDumper() {
		yaml = new Yaml(options());
	}

	private DumperOptions options() {
		final DumperOptions options = new DumperOptions();
		options.setCanonical(false);
		options.setDefaultFlowStyle(DumperOptions.FlowStyle.BLOCK);
		options.setExplicitStart(true);
		options.setExplicitEnd(false);
		options.setWidth(YAML_LINE_WIDTH);
		return options;
	}

	public String dump(Object obj) {
		return yaml.dump(obj);
	}
}
