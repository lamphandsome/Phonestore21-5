var token = localStorage.getItem("token");
var size = 10;
async function loadCategory(page, param) {
    if (param == null) {
        param = "";
    }
    var url = 'http://localhost:8080/api/category/public/search?page=' + page + '&size=' + size + '&q=' + param;
    const response = await fetch(url, {
        method: 'GET'
    });
    var result = await response.json();
    console.log(result)
    var list = result.content;
    var totalPage = result.totalPages;

    var main = '';
    for (i = 0; i < list.length; i++) {
        main += `<tr>
                    <td>${list[i].id}</td>
                    <td>${list[i].name}</td>
                    <td>${list[i].categoryType}</td>
                    <td class="sticky-col">
                        <i onclick="deleteCategory(${list[i].id})" class="fa fa-trash-alt iconaction"></i>
                        <a data-bs-toggle="modal" data-bs-target="#addtk" href="#" onclick="loadACategory(${list[i].id})"><i class="fa fa-edit iconaction"></i></a>
                    </td>
                </tr>`
    }
    document.getElementById("listcategory").innerHTML = main
    var mainpage = ''
    for (i = 1; i <= totalPage; i++) {
        mainpage += `<li onclick="loadCategory(${(Number(i) - 1)},${param})" class="page-item"><a class="page-link" href="#listsp">${i}</a></li>`
    }
    document.getElementById("pageable").innerHTML = mainpage
}

async function loadTypeCategory() {
    var url = 'http://localhost:8080/api/category/public/get-all-category-type';
    const response = await fetch(url, {
    });
    var list = await response.json();
    var main = '';
    for (i = 0; i < list.length; i++) {
        main += `<option value="${list[i]}">${list[i]}</option>`
    }
    document.getElementById("catetype").innerHTML = main
}



async function loadACategory(id) {
    var url = 'http://localhost:8080/api/category/admin/findById?id=' + id;
    const response = await fetch(url, {
        method: 'GET',
        headers: new Headers({
            'Authorization': 'Bearer ' + token
        })
    });
    var result = await response.json();
    document.getElementById("idcate").value = result.id
    document.getElementById("catename").value = result.name
    document.getElementById("catetype").value = result.categoryType
}

function clearData(){
    document.getElementById("idcate").value = ""
    document.getElementById("catename").value = ""
}


async function saveCategory() {
    var id = document.getElementById("idcate").value
    var catename = document.getElementById("catename").value
    var catetype = document.getElementById("catetype").value

    var url = 'http://localhost:8080/api/category/admin/create';
    if (id != "" && id != null) {
        url = 'http://localhost:8080/api/category/admin/update';
    }
    var category = {
        "id": id,
        "name": catename,
        "categoryType": catetype,
    }
    const response = await fetch(url, {
        method: 'POST',
        headers: new Headers({
            'Authorization': 'Bearer ' + token,
            'Content-Type': 'application/json'
        }),
        body: JSON.stringify(category)
    });
    if (response.status < 300) {
        toastr.success("thêm/sửa danh mục thành công!");
        loadCategory(0,"");
        $("#addtk").modal('hide');
    }
    if (response.status == exceptionCode) {
        var result = await response.json()
        toastr.warning(result.defaultMessage);
    }
}

async function deleteCategory(id) {
    const result = await Swal.fire({
            title: 'Xác nhận',
            text: "Bạn chắc chắn muốn xóa danh mục này?",
            icon: 'warning',
            showCancelButton: true,
            confirmButtonText: 'Đồng ý',
            cancelButtonText: 'Hủy',
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33'
        });
        if (!result.isConfirmed) return;
    if (con == false) {
        return;
    }
    var url = 'http://localhost:8080/api/category/admin/delete?id=' + id;
    const response = await fetch(url, {
        method: 'DELETE',
        headers: new Headers({
            'Authorization': 'Bearer ' + token
        })
    });
    if (response.status < 300) {
        toastr.success("xóa danh mục thành công!");
        loadCategory(0,"");
    }
    if (response.status == exceptionCode) {
        var result = await response.json()
        toastr.warning(result.defaultMessage);
    }
}

async function loadCategoryProduct() {
    var url = 'http://localhost:8080/api/category/public/findAll';
    const response = await fetch(url, {
        method: 'GET'
    });
    var list = await response.json();

    var main = '<option value="">Tất cả danh mục</option>';
    for (i = 0; i < list.length; i++) {
        main += `<option value="${list[i].id}">${list[i].name}</option>`
    }
    document.getElementById("danhmuc").innerHTML = main
}