// cart.js (sửa confirm -> SweetAlert2, fix toastr.error)

var idColorCart = -1;

async function addCart(type) {
    if (idColorCart < 1) {
        toastr.warning("Bạn chưa chọn màu sắc");
        return;
    }
    if (token == null) {
        toastr.warning("Hãy đăng nhập để thực hiện chức năng này");
        return;
    }

    var url = 'http://localhost:8080/api/cart/user/create?idcolor=' + idColorCart;
    const response = await fetch(url, {
        method: 'POST',
        headers: { 'Authorization': 'Bearer ' + token }
    });

    if (response.status < 300) {
        toastr.success("Thêm giỏ hàng thành công!");
        countCart();
        if (type == "MUANGAY") {
            window.location.href = 'giohang';
        }
    } else {
        toastr.error("Thêm giỏ hàng thất bại!");
    }
}

async function loadAllCart() {
    if (token == null) {
        window.location.href = 'dangnhap';
    }

    const url = 'http://localhost:8080/api/cart/user/my-cart';
    const response = await fetch(url, {
        method: 'GET',
        headers: { 'Authorization': 'Bearer ' + token }
    });

    const list = await response.json();
    let main = '';
    let totalAmount = 0;
    let totalCart = 0;

    for (let i = 0; i < list.length; i++) {
        totalAmount += list[i].productColor.price * list[i].quantity;
        totalCart += Number(list[i].quantity);

        main += `<tr>
            <td>
                <a href=""><img class="imgprocart" src="${list[i].product.imageBanner}"></a>
                <div class="divnamecart">
                    <a href="" class="nameprocart">${list[i].product.name}</a>
                    <p class="sizecart">${list[i].productColor.name} / ${list[i].productStorage.ram} - ${list[i].productStorage.rom}</p>
                </div>
            </td>
            <td><p class="boldcart">${formatmoney(list[i].productColor.price)}</p></td>
            <td>
                <div class="clusinp">
                    <button onclick="upDownQuantity(${list[i].id},'UP')" class="cartbtn"> + </button>
                    <input value="${list[i].quantity}" class="inputslcart">
                    <button onclick="upDownQuantity(${list[i].id},'DOWN')" class="cartbtn"> - </button>
                </div>
            </td>
            <td>
                <div class="tdpricecart">
                    <p class="boldcart">${formatmoney(list[i].productColor.price * list[i].quantity)}</p>
                    <p onclick="removeCart(${list[i].id})" class="delcart"><i class="fa fa-trash-o facartde"></i></p>
                </div>
            </td>
        </tr>`;
    }

    document.getElementById("listcartDes").innerHTML = main;
    document.getElementById("tonggiatien").innerHTML = formatmoney(totalAmount);
    document.getElementById("soluonggiohang").innerHTML = totalCart;

    if (list.length == 0) {
        document.getElementById("listcartDes").innerHTML = `<tr><td colspan="4"><h3>Giỏ hàng trống</h3></td></tr>`;
    }
}

async function removeCart(id) {
    Swal.fire({
        title: 'Xác nhận',
        text: 'Bạn muốn xóa sản phẩm này khỏi giỏ hàng?',
        icon: 'warning',
        showCancelButton: true,
        confirmButtonText: 'Xóa',
        cancelButtonText: 'Hủy'
    }).then(async (result) => {
        if (!result.isConfirmed) return;

        const url = 'http://localhost:8080/api/cart/user/delete?id=' + id;
        const response = await fetch(url, {
            method: 'DELETE',
            headers: { 'Authorization': 'Bearer ' + token }
        });

        if (response.status < 300) {
            await loadAllCart();
        }
    });
}

async function upDownQuantity(id, type) {
    let url = 'http://localhost:8080/api/cart/user/down-cart?id=' + id;
    if (type == "UP") {
        url = 'http://localhost:8080/api/cart/user/up-cart?id=' + id;
    }

    const response = await fetch(url, {
        method: 'GET',
        headers: { 'Authorization': 'Bearer ' + token }
    });

    if (response.status < 300) {
        await loadAllCart();
    }
}
