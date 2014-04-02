package net.snet.ledger.service;

/**
 * Created by admin on 2.4.14.
 */
public interface Record {
	int sequence();

	String id();

	String message();

	boolean isOk();
}
