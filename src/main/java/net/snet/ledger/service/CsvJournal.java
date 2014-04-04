package net.snet.ledger.service;

import com.google.common.base.Splitter;
import com.google.common.collect.Iterables;

import java.io.*;

/**
 * Created by admin on 2.4.14.
 */
public class CsvJournal implements Journal {
	private final File file;
	private final BufferedReader reader;
	private String nextLine;

	public CsvJournal(File file) {
		this.file = file;
		try {
			this.reader = new BufferedReader(new FileReader(file));
		} catch (FileNotFoundException e) {
			throw new RuntimeException(e);
		}
		nextLine = nextLine();
	}

	@Override
	public boolean hasNext() {
		return nextLine != null;
	}

	@Override
	public Record next() {
		final String[] fields = Iterables.toArray(Splitter.on("|").split(nextLine), String.class);
		nextLine = nextLine();
		return new Record() {
			@Override
			public int sequence() {
				return Integer.valueOf(fields[0]);
			}

			@Override
			public String id() {
				return fields[1];
			}

			@Override
			public String message() {
				return fields[2];
			}

			@Override
			public boolean isOk() {
				return "OK".equals(fields[2]);
			}
		};
	}

	@Override
	public void remove() {
		throw new UnsupportedOperationException();
	}

	private String nextLine() {
		String line;
		try {
			line = reader.readLine();
			while (line != null && "".equals(line.trim())) {
				line = reader.readLine();
			}
		} catch (IOException e) {
			throw new RuntimeException(e);
		}
		if (line == null) {
			try {
				reader.close();
			} catch (IOException e) {
				throw new RuntimeException(e);
			}
		}
		return line;
	}
}
