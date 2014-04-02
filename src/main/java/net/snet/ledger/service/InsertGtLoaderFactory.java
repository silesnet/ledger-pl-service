package net.snet.ledger.service;

/**
 * Created by admin on 2.4.14.
 */
public class InsertGtLoaderFactory implements LoaderFactory {

	public enum Type {INVOICE, CUSTOMER}

	private final Type type;

	public InsertGtLoaderFactory(Type type) {
		this.type = type;
	}

	@Override
	public Loader newLoader() {
		return null;
	}
}
