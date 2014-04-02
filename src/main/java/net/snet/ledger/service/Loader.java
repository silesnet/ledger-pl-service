package net.snet.ledger.service;

import java.io.File;

/**
 * Created by admin on 2.4.14.
 */
public interface Loader {
	Journal load(File file);
}
