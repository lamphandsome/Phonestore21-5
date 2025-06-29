package com.web.servive;

import com.web.dto.request.InvoiceRequest;
import com.web.dto.response.InvoiceResponse;
import com.web.entity.Invoice;
import com.web.entity.Shipper;
import com.web.entity.User;
import com.web.enums.PayType;
import com.web.enums.StatusInvoice;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.sql.Date;
import java.util.List;

@Service
public interface InvoiceService {
    public List<Invoice> findByShipperAndFilter(Long shipperId, String start, String end, String payType);;

    public List<Invoice> findInvoicesWithStatus();

    public void assignShipper(Long invoiceId, Shipper shipper);

    public InvoiceResponse create(InvoiceRequest invoiceRequest);

    public InvoiceResponse updateStatus(Long invoiceId, StatusInvoice statusInvoice);

    public List<InvoiceResponse> findByUser();

    public Page<InvoiceResponse> findAll(Date from, Date to, Pageable pageable);

    public InvoiceResponse cancelInvoice(Long invoiceId);

    public InvoiceResponse findById(Long invoiceId);

    public InvoiceResponse findByIdForAdmin(Long invoiceId);

    public InvoiceResponse timKiemDonHang(Long id, String phone);

    public Page<InvoiceResponse> findAllFull(Date from, Date to, PayType payType, StatusInvoice statusInvoice, Pageable pageable);
}
