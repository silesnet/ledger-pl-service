package net.snet.ledger.service;

/**
 * Created by admin on 2.4.14.
 */
public class CsvJournal implements Journal {
	@Override
	public boolean hasNext() {
		return false;
	}

	@Override
	public Record next() {
		return null;
	}

	@Override
	public void remove() {

	}
}
