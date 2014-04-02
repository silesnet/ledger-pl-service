package net.snet.ledger.service;

import java.io.File;

/**
 * Created by admin on 2.4.14.
 */
public interface Batch {

	File file();

	void header(Object header);

	void append(Object item);

	void trailer(Object trailer);

	boolean isReady();
}
