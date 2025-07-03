// checkout.js (đã sửa hoàn chỉnh)

var token = localStorage.getItem("token");
var exceptionCode = 417;

async function checkroleUser() {
    const url = 'http://localhost:8080/api/user/check-role-user';
    const response = await fetch(url, {
        method: 'GET',
        headers: { 'Authorization': 'Bearer ' + token }
    });
    if (response.status > 300) {
        window.location.replace('login');
    }
}

var total = 0;
var listSize = [];
var giamgia = 0;

async function loadCartCheckOut() {
    let soluongsp = 0;
    const countRes = await fetch('http://localhost:8080/api/cart/user/count-cart', {
        method: 'GET',
        headers: { 'Authorization': 'Bearer ' + token }
    });
    const count = await countRes.text();
    if (count == 0) {
        await Swal.fire({
            icon: 'warning',
            title: 'Thông báo',
            text: 'Bạn chưa có sản phẩm nào trong giỏ hàng!',
            confirmButtonText: 'OK'
        });
        window.location.replace("giohang");
        return;
    }


    const res = await fetch('http://localhost:8080/api/cart/user/my-cart', {
        method: 'GET',
        headers: { 'Authorization': 'Bearer ' + token }
    });
    const list = await res.json();
    let main = '';
    for (let i = 0; i < list.length; i++) {
        soluongsp += list[i].quantity;
        total += list[i].quantity * list[i].productColor.price;
        main += `<div class="row">
                    <div class="col-lg-2 col-md-3 col-sm-3 col-3 colimgcheck">
                        <img src="${list[i].product.imageBanner}" class="procheckout">
                        <span class="slpro">${list[i].quantity}</span>
                    </div>
                    <div class="col-lg-7 col-md-6 col-sm-6 col-6">
                        <span class="namecheck">${list[i].product.name}</span>
                        <span class="colorcheck">${list[i].productColor.name} / ${list[i].productStorage.ram} - ${list[i].productStorage.rom}</span>
                    </div>
                    <div class="col-lg-3 col-md-3 col-sm-3 col-3 pricecheck">
                        <span>${formatmoneyCheck(list[i].quantity * list[i].productColor.price)}</span>
                    </div>
                </div>`;
    }

    document.getElementById("listproductcheck").innerHTML = main;
    document.getElementById("totalAmount").innerHTML = formatmoneyCheck(total);
    document.getElementById("totalfi").innerHTML = formatmoneyCheck(total);
}

function formatmoneyCheck(money) {
    return new Intl.NumberFormat('vi-VN', {
        style: 'currency',
        currency: 'VND'
    }).format(money);
}

var voucherId = null;
var voucherCode = null;
var discountVou = 0;

async function loadVoucher() {
    const code = document.getElementById("codevoucher").value;
    const url = 'http://localhost:8080/api/voucher/public/findByCode?code=' + code + '&amount=' + (total - 20000);
    const response = await fetch(url);
    const result = await response.json();

    if (response.status == exceptionCode) {
        document.getElementById("messerr").innerHTML = result.defaultMessage;
        document.getElementById("blockmessErr").style.display = 'block';
        document.getElementById("blockmess").style.display = 'none';
        voucherCode = voucherId = null;
        discountVou = 0;
        document.getElementById("moneyDiscount").innerHTML = formatmoneyCheck(0);
        document.getElementById("totalfi").innerHTML = formatmoneyCheck(total);
    }

    if (response.status < 300) {
        voucherId = result.id;
        voucherCode = result.code;
        discountVou = result.discount;
        document.getElementById("blockmessErr").style.display = 'none';
        document.getElementById("blockmess").style.display = 'block';
        document.getElementById("moneyDiscount").innerHTML = formatmoneyCheck(result.discount);
        document.getElementById("totalfi").innerHTML = formatmoneyCheck(total - discountVou);
    }
}

function checkout() {
    Swal.fire({
        title: 'Xác nhận',
        text: 'Bạn có chắc chắn muốn đặt hàng?',
        icon: 'question',
        showCancelButton: true,
        confirmButtonText: 'Đặt hàng',
        cancelButtonText: 'Hủy'
    }).then((result) => {
        if (!result.isConfirmed) return;

        const paytype = $('input[name=paytype]:checked').val();
        if (paytype === "momo") {
            requestPayMentMomo();
        } else if (paytype === "cod") {
            paymentCod();
        }
    });
}

async function requestPayMentMomo() {
    const ghichu = document.getElementById("ghichudonhang").value;
    const diachi = document.getElementById("sodiachi").value;
    window.localStorage.setItem('ghichudonhang', ghichu);
    window.localStorage.setItem('voucherCode', voucherCode);
    window.localStorage.setItem('shipCost', phiShip);
    window.localStorage.setItem('sodiachi', diachi);

    const urlinit = 'http://localhost:8080/api/urlpayment';
    const paymentDto = {
        "content": "Bảo ngọc mobile",
        "returnUrl": 'http://localhost:8080/thanhcong',
        "notifyUrl": 'http://localhost:8080/thanhcong',
        "codeVoucher": voucherCode,
        "shipCost": phiShip,
    };

    const res = await fetch(urlinit, {
        method: 'POST',
        headers: {
            'Authorization': 'Bearer ' + token,
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(paymentDto)
    });

    const result = await res.json();
    if (res.status < 300) {
        window.open(result.url, '_blank');
    } else if (res.status == exceptionCode) {
        toastr.warning(result.defaultMessage);
    }
}

async function paymentMomo() {
    const uls = new URL(document.URL);
    const orderId = uls.searchParams.get("orderId");
    const requestId = uls.searchParams.get("requestId");
    const note = window.localStorage.getItem("ghichudonhang");

    const orderDto = {
        "payType": "MOMO",
        "userAddressId": window.localStorage.getItem("sodiachi"),
        "voucherCode": window.localStorage.getItem("voucherCode"),
        "note": note,
        "requestIdMomo": requestId,
        "orderIdMomo": orderId,
        "shipCost": window.localStorage.getItem("shipCost")
    };

    const url = 'http://localhost:8080/api/invoice/user/create';
    const res = await fetch(url, {
        method: 'POST',
        headers: {
            'Authorization': 'Bearer ' + token,
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(orderDto)
    });

    const result = await res.json();
    if (res.status < 300) {
        document.getElementById("thanhcong").style.display = 'block';
    } else if (res.status == exceptionCode) {
        document.getElementById("thatbai").style.display = 'block';
        document.getElementById("thanhcong").style.display = 'none';
        document.getElementById("errormess").innerHTML = result.defaultMessage;
    }
}

async function paymentCod() {
    const note = document.getElementById("ghichudonhang").value;
    const orderDto = {
        "payType": "COD",
        "userAddressId": document.getElementById("sodiachi").value,
        "voucherCode": voucherCode,
        "note": note,
        "shipCost": phiShip
    };

    const url = 'http://localhost:8080/api/invoice/user/create';
    const res = await fetch(url, {
        method: 'POST',
        headers: {
            'Authorization': 'Bearer ' + token,
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(orderDto)
    });

    const result = await res.json();
    if (res.status < 300) {
        Swal.fire({
            title: 'Thành công!',
            text: 'Đặt hàng thành công!',
            icon: 'success',
            confirmButtonText: 'OK'
        }).then(() => {
            window.location.replace("taikhoan#invoice");
        });
    } else if (res.status == exceptionCode) {
        Swal.fire('Lỗi', result.defaultMessage, 'warning');
    }
}
