package net.snet.ledger.service;

import java.util.List;

/**
 * Created by admin on 2.4.14.
 */
public interface RestResource {
	List poll();

	void patch(List items);
}
