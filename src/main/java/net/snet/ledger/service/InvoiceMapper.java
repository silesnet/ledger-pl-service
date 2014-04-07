package net.snet.ledger.service;

import com.google.common.collect.Lists;
import com.google.common.collect.Maps;
import org.joda.time.DateTime;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Map;

/**
 * Created by admin on 7.4.14.
 */
public class InvoiceMapper implements Mapper {
	@Override
	public Map map(Map data) {
		final Map<Object, Object> invoice = Maps.newHashMap();
		invoice.put("number", invoiceNumber(data.get("number")));
		invoice.put("customerId", ((Map) data.get("customer")).get("symbol"));
		invoice.put("invoiceDate", isoDate(data.get("billing_date")));
		invoice.put("dueDate", isoDate(data.get("purge_date")));
		final ArrayList<Object> items = Lists.newArrayList();
		invoice.put("items", items);
		for (Object lineObj : (Collection) data.get("lines")) {
			Map<Object, Object> line = (Map) lineObj;
			Map<Object, Object> item = Maps.newHashMap();
			item.put("name", line.get("text") + ", " + period(invoice.get("period_from"), invoice.get("period_to")));
			item.put("unitPrice", line.get("price"));
			item.put("quantity", line.get("amount"));
			item.put("unit", unit(line.get("is_display_unit")));
			items.add(item);
		}
		return invoice;
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


}
