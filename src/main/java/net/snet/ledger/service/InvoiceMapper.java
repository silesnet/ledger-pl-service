package net.snet.ledger.service;

import com.google.common.collect.Lists;
import com.google.common.collect.Maps;
import org.joda.time.DateTime;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Map;

public class InvoiceMapper implements Mapper {
	private final Map<Integer, Integer> pctToIdMap;
	private final String accountantName;

	public InvoiceMapper(Map<Integer, Integer> pctToIdMap, String accountantName) {
		this.pctToIdMap = pctToIdMap;
		this.accountantName = accountantName;
	}

	@Override
	public Map map(Map data) {
		// keys would preserve insertion order, using LinkedHashMap
		final Map<Object, Object> invoice = Maps.newLinkedHashMap();
		invoice.put("number", invoiceNumber(data.get("number")));
		invoice.put("originalNumber", data.get("number"));
		invoice.put("customerId", ((Map) data.get("customer")).get("symbol"));
		invoice.put("customerOriginalId", ((Map) data.get("customer")).get("id"));
		invoice.put("customerName", sanitizeForYaml(((Map) data.get("customer")).get("name")));
		invoice.put("invoiceDate", isoDate(data.get("billing_date")));
		invoice.put("dueDate", isoDate(data.get("purge_date")));
		invoice.put("deliveryDate", lastOfInvoicingMonth(data.get("billing_date")));
		// 'totalNet' key placeholder, would be rewritten, keeping things ordered
		invoice.put("totalNet", null);
		invoice.put("accountantName", accountantName);
		final ArrayList<Object> items = Lists.newArrayList();
		invoice.put("items", items);
		BigDecimal totalNet = BigDecimal.ZERO;
		for (Object lineObj : (Collection) data.get("lines")) {
			Map line = (Map) lineObj;
			Map<Object, Object> item = Maps.newLinkedHashMap();
			item.put("name", sanitizeForYaml(line.get("text")) + ", " + period(data.get("period_from"), data.get("period_to")));
			item.put("unitPrice", line.get("price"));
			item.put("quantity", line.get("amount"));
			item.put("unit", unit(line.get("is_display_unit")));
			item.put("vatId", pctToIdMap.get(Integer.valueOf(data.get("vat").toString())));
			item.put("vatPct", data.get("vat"));
			items.add(item);
			totalNet = totalNet.add(lineNet(line));
		}
		invoice.put("totalNet", totalNet.doubleValue());
		return invoice;
	}

	private String sanitizeForYaml(Object value) {
		if (value == null) {
			return null;
		}
		return value.toString()
									.replaceAll("\n", " ")
									.replaceAll("\r", " ")
									.replaceAll("\t", " ");
	}

	private String unit(Object is_display_unit) {
		return Boolean.valueOf(is_display_unit.toString()) ? "mies." : "szt.";
	}

	private String period(Object start, Object end) {
		return end != null ? period(end) : period(start);
	}

	private String period(Object date) {
		return new DateTime(date).toString("MM/yyyy");
	}

	private String invoiceNumber(Object number) {
		return Long.valueOf(number.toString().substring(4)).toString();
	}

	private String isoDate(Object date) {
		return new DateTime(date).toString("yyyy-MM-dd");
	}

	private String lastOfInvoicingMonth(Object date) {
		return new DateTime(date).dayOfMonth().withMaximumValue().toString("yyyy-MM-dd");
	}

	private BigDecimal lineNet(Map line) {
		return toBigDecimal(line, "price").multiply(toBigDecimal(line, "amount"));
	}

	private BigDecimal toBigDecimal(Map map, String key) {
		return BigDecimal.valueOf(Double.valueOf(map.get(key).toString()));
	}

}
