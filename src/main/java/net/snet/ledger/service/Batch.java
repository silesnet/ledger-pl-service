package net.snet.ledger.service;

import com.google.common.base.Optional;

import java.io.File;

/**
 * Created by admin on 2.4.14.
 */
public interface Batch {

	File file();

	void header(Optional header);

	void append(Object item);

	void trailer(Optional trailer);

	boolean isReady();
}
