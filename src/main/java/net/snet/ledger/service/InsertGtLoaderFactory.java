package net.snet.ledger.service;

import java.io.File;

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
		return new Loader() {
			@Override
			public Journal load(File file) {
				return new Journal() {
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
						throw new UnsupportedOperationException();
					}
				};
			}
		};
	}
}
