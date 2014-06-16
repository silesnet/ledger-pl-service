package net.snet.ledger.service;

import com.google.common.base.Optional;
import com.google.common.collect.ImmutableMap;
import com.google.common.collect.Maps;

import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class CustomerMapper implements Mapper {

	public static final int CUSTOMER_MAX_NAME = 51;
	public static final ImmutableMap<Integer, String> COUNTRY_MAP = ImmutableMap.of(10, "CZ", 20, "PL", 30, "SK");

	@Override
	public Map map(Map data) {
		// keys would preserve insertion order, using LinkedHashMap
		final Map<Object, Object> customer = Maps.newLinkedHashMap();
		customer.put("id", Long.valueOf(data.get("id").toString()));
		customer.put("surrogateId", data.get("symbol"));
		customer.put("isNew", isNew(data.get("synchronized")));
		final String dic = Optional.fromNullable(data.get("dic")).or("").toString();
		customer.put("isBusiness", (dic.length() > 0));
		String name = data.get("name").toString().trim();
		if (name.length() > CUSTOMER_MAX_NAME) {
			name = name.substring(0, CUSTOMER_MAX_NAME - 3) + "...";
		}
		customer.put("name", name);
		String fullName = data.get("name").toString().trim();
		String supplementaryName = Optional.fromNullable(data.get("supplementary_name")).or("").toString();
		if (supplementaryName.length() > 0) {
			fullName = fullName + " - " + supplementaryName;
		}
		customer.put("fullName", fullName);
		customer.put("publicId", Optional.fromNullable(data.get("public_id")).or("").toString());
		if (dic.length() > 0) {
			customer.put("vatId", dic);
		}
		final Map<Object, Object> address = Maps.newLinkedHashMap();
		final Street street = new Street(data.get("street").toString());
		address.put("street", street.street());
		if (street.streetNumber().isPresent()) {
			address.put("streetNumber", street.streetNumber().get());
		}
		if (street.premiseNumber.isPresent()) {
			address.put("premiseNumber", street.premiseNumber().get());
		}
		address.put("city", data.get("city"));
		address.put("postalCode", data.get("postal_code"));
		address.put("country", COUNTRY_MAP.get(Integer.valueOf(data.get("country").toString())));
		customer.put("address", address);
		customer.put("email", data.get("email"));
		final String phone = Optional.fromNullable(data.get("phone")).or("").toString();
		if (phone.length() > 0) {
			customer.put("phone", data.get("phone"));
		}
		final String bankAccount = Optional.fromNullable(data.get("account_no")).or("").toString();
		if (bankAccount.length() > 0) {
			customer.put("bankAccount", bankAccount);
		}
		return customer;
	}

	private static class Street {
		private static Pattern STREET_PATTERN = Pattern.compile("(.*)\\s+(\\S+?)(/(\\S+))?");

		private final String street;
		private final Optional<String> streetNumber;
		private final Optional<String> premiseNumber;

		private Street(String fullStreet) {
			final Matcher matcher = STREET_PATTERN.matcher(fullStreet);
			if (matcher.matches()) {
				this.street = matcher.group(1);
				this.streetNumber = Optional.fromNullable(matcher.group(2));
				this.premiseNumber = Optional.fromNullable(matcher.group(4));
			} else {
				this.street = fullStreet;
				this.streetNumber = Optional.absent();
				this.premiseNumber = Optional.absent();
			}
		}

		public String street() {
			return street;
		}

		public Optional<String> streetNumber() {
			return streetNumber;
		}

		public Optional<String> premiseNumber() {
			return premiseNumber;
		}
	}

	private boolean isNew(Object aSynchronized) {
		return aSynchronized == null;
	}
}
