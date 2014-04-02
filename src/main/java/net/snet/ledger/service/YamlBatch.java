package net.snet.ledger.service;

import java.io.File;
import java.util.Map;

/**
 * Created by sikorric on 2014-04-02.
 */
public class YamlBatch implements Batch {
	public void add(Map map) {

	}

	@Override
	public File file() {
		return null;
	}

	@Override
	public void header(Object header) {

	}

	@Override
	public void append(Object item) {

	}

	@Override
	public void trailer(Object trailer) {

	}

	@Override
	public boolean isReady() {
		return false;
	}
}
