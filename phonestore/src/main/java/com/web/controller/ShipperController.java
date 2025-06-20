package com.web.controller;

import com.web.entity.Invoice;
import com.web.entity.Shipper;
import com.web.entity.User;
import com.web.enums.PayType;
import com.web.enums.StatusInvoice;
import com.web.repository.InvoiceRepository;
import com.web.repository.ShipperRepository;
import com.web.servive.InvoiceService; // Sửa lỗi chính tả từ servive
import com.web.servive.UserService;   // Sửa lỗi chính tả từ servive
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity; // Import ResponseEntity
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException; // Thêm import này

import java.security.Principal;
import java.util.List;
import java.util.Optional; // Import Optional
import java.util.HashMap;
import java.util.Map;

@Controller
@RequestMapping("/shipper")
public class ShipperController {

    @Autowired
    private InvoiceService invoiceService;

    @Autowired
    private UserService userService;

    @Autowired
    ShipperRepository shipperRepository;

    @Autowired
    private InvoiceRepository invoiceRepository; // Đã thêm private và final nếu có thể

    // --- Endpoint để nhận đơn hàng AJAX ---
    @PostMapping("/accept-order")
    @ResponseBody // Trả về JSON hoặc chuỗi
    public ResponseEntity<Map<String, String>> acceptOrderAjax(
            @RequestParam("invoiceId") Long invoiceId,
            Principal principal
    ) {
        Map<String, String> response = new HashMap<>();
        if (principal == null) {
            response.put("status", "error");
            response.put("message", "Người dùng chưa đăng nhập.");
            return new ResponseEntity<>(response, HttpStatus.UNAUTHORIZED); // 401 Unauthorized
        }

        try {
            User currentUser = userService.findByUsername(principal.getName());
            if (currentUser == null) {
                response.put("status", "error");
                response.put("message", "Không tìm thấy thông tin người dùng.");
                return new ResponseEntity<>(response, HttpStatus.NOT_FOUND); // 404 Not Found
            }
            Shipper shipper = shipperRepository.findShipperByUserId(currentUser.getId());
            invoiceService.assignShipper(invoiceId, shipper);
            response.put("status", "success");
            response.put("message", "Đã nhận đơn hàng thành công. Trạng thái: DANG_GUI");
            return new ResponseEntity<>(response, HttpStatus.OK); // 200 OK
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Có lỗi xảy ra khi nhận đơn hàng: " + e.getMessage());
            return new ResponseEntity<>(response, HttpStatus.INTERNAL_SERVER_ERROR); // 500 Internal Server Error
        }
    }

    // --- Endpoint hiển thị danh sách đơn hàng ---
    @GetMapping()
    public String getShipperOrders(
            @RequestParam(value = "start", required = false) String startDate,
            @RequestParam(value = "end", required = false) String endDate,
            @RequestParam(value = "type", required = false) String payType,
            Model model,
            Principal principal
    ) {
        if (principal == null) {
            return "redirect:/dangnhap"; // Chuyển hướng nếu chưa đăng nhập
        }

        // Lấy thông tin user đang đăng nhập
        User currentUser = userService.findByUsername(principal.getName());
        if (currentUser == null) {
            // Xử lý trường hợp không tìm thấy user (có thể do session không hợp lệ)
            // Có thể log lỗi và chuyển hướng về trang đăng nhập
            return "redirect:/dangnhap?error=userNotFound";
        }

        // Chuẩn hóa payType cho việc lọc
        String filterPayType = (payType != null && !payType.equals("-1")) ? payType : null;
        Shipper shipper = shipperRepository.findShipperByUserId(currentUser.getId());

        // Lấy danh sách hóa đơn
        List<Invoice> myOrders = invoiceService.findByShipperAndFilter(shipper.getId(), startDate, endDate, filterPayType);
        // Đảm bảo findByShipperDone trả về các hóa đơn đã hoàn thành (DA_NHAN)
        List<Invoice> myOrdersDone = invoiceRepository.findByShipperAndStatus(shipper.getId(), StatusInvoice.DA_NHAN);
        List<Invoice> availableOrders = invoiceService.findInvoicesWithStatus(); // Đảm bảo lấy đúng trạng thái CHỜ_NHẬN

        // Đặt dữ liệu vào model
        model.addAttribute("myOrders", myOrders);
        model.addAttribute("myOrdersDone", myOrdersDone);
        model.addAttribute("availableOrders", availableOrders);

        // Đặt lại các giá trị lọc để giữ trên form Thymeleaf
        model.addAttribute("selectedStart", startDate);
        model.addAttribute("selectedEnd", endDate);
        model.addAttribute("selectedPayType", payType); // Giữ nguyên giá trị "-1" để hiển thị đúng trên select box

        return "shipper"; // Trả về tên view Thymeleaf
    }

    // --- Endpoint để đánh dấu đã giao hàng AJAX ---
    @PostMapping("/mark-delivered")
    @ResponseBody // Trả về JSON hoặc chuỗi
    public ResponseEntity<Map<String, String>> markDelivered(@RequestParam Long invoiceId) {
        Map<String, String> response = new HashMap<>();
        try {
            Optional<Invoice> optionalInvoice = invoiceRepository.findById(invoiceId);
            if (optionalInvoice.isEmpty()) {
                response.put("status", "error");
                response.put("message", "Không tìm thấy hóa đơn với ID: " + invoiceId);
                return new ResponseEntity<>(response, HttpStatus.NOT_FOUND); // 404 Not Found
            }

            Invoice invoice = optionalInvoice.get();
            invoice.setStatusInvoice(StatusInvoice.DA_NHAN); // Đảm bảo đây là trạng thái đúng cho "đã giao xong"
            invoice.setPayType(PayType.MOMO);
            invoiceRepository.save(invoice);
            response.put("status", "success");
            response.put("message", "Cập nhật trạng thái thành công.");
            return new ResponseEntity<>(response, HttpStatus.OK); // 200 OK
        } catch (Exception e) {
            response.put("status", "error");
            response.put("message", "Có lỗi xảy ra khi đánh dấu đã giao hàng: " + e.getMessage());
            return new ResponseEntity<>(response, HttpStatus.INTERNAL_SERVER_ERROR); // 500 Internal Server Error
        }
    }
}