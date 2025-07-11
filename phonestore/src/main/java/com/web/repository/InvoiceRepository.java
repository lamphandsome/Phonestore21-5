package com.web.repository;

import com.web.entity.Category;
import com.web.entity.Invoice;
import com.web.enums.PayType;
import com.web.enums.StatusInvoice;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.transaction.annotation.Transactional;

import java.sql.Date;
import java.time.LocalDate;
import java.util.List;

public interface InvoiceRepository extends JpaRepository<Invoice,Long> {


    @Query("SELECT i FROM Invoice i WHERE i.shipper.id = :shipperId "
            + "AND (:startDate IS NULL OR i.createdDate >= :startDate) "
            + "AND (:endDate IS NULL OR i.createdDate <= :endDate) "
            + "AND i.statusInvoice = 2"
            + "AND (:payType IS NULL OR i.payType = :payType)")
    List<Invoice> findByShipperWithFilters(
            @Param("shipperId") Long shipperId,
            @Param("startDate") java.util.Date startDate,      // phải là java.util.Date
            @Param("endDate") java.util.Date endDate,
            @Param("payType") PayType payType); // <- Phải là enum


    @Query("SELECT i FROM Invoice i WHERE i.statusInvoice = 1")
    List<Invoice> findByStatusInvoice();

    @Query("SELECT i FROM Invoice i WHERE i.shipper.id = ?1 and i.statusInvoice = 3")
    List<Invoice> findByShipperDone(Long shipperId);

    @Query("SELECT i FROM Invoice i WHERE i.shipper.id = ?1 AND i.statusInvoice = ?2")
    List<Invoice> findByShipperAndStatus(Long shipperId, StatusInvoice status);


    @Modifying
    @Transactional
    @Query("update Invoice i set i.userAddress = null where i.userAddress.id = ?1")
    int setNull(Long userAdressId);

    @Modifying
    @Transactional
    @Query("update Invoice i set i.voucher = null where i.voucher.id = ?1")
    int setNullVoucher(Long voucherId);

    @Query("select i from Invoice i where i.userAddress.user.id = ?1")
    public List<Invoice> findByUser(Long userId);

    @Query("select i from Invoice i where i.createdDate >= ?1 and i.createdDate <= ?2")
    public Page<Invoice> findByDate(Date from, Date to, Pageable pageable);


    @Query("select i from Invoice i where i.createdDate >= ?1 and i.createdDate <= ?2 and i.payType = ?3")
    public Page<Invoice> findByDateAndPaytype(Date from, Date to, PayType payType, Pageable pageable);


    @Query(value = "select sum(i.total_amount) from invoice i where Month(i.created_date) = ?1 and Year(i.created_date) = ?2 and (i.pay_type = 0 or i.status_invoice = ?3)", nativeQuery = true)
    public Double calDt(Integer thang, Integer month, Integer index);

    @Query(value = "select sum(i.total_amount) from invoice i \n" +
            "WHERE (i.status_invoice = ?2 or i.pay_type = 0 ) and i.created_date = ?1", nativeQuery = true)
    public Double revenueByDate(Date ngay, Integer index);

    @Query(value = "select count(i.id) from invoice i\n" +
            "where i.status_invoice = ?2 and i.status_update_date = ?1",nativeQuery = true)
    public Double numInvoiceToDay(Date ngay, Integer index);


    @Query("select i from Invoice i where i.createdDate >= ?1 and i.createdDate <= ?2 and i.statusInvoice = ?3")
    public Page<Invoice> findByDateAndStatus(Date from, Date to, StatusInvoice status, Pageable pageable);

    @Query("select i from Invoice i where i.createdDate >= ?1 and i.createdDate <= ?2 and i.payType = ?3 and i.statusInvoice = ?4")
    public Page<Invoice> findByDateAndPaytypeAndStatus(Date from, Date to, PayType payType,StatusInvoice status, Pageable pageable);

}
