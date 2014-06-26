package net.snet.ledger.service;

import java.util.List;

public interface RestResource {
	String name();

	List poll();

	void patch(List items);
}
