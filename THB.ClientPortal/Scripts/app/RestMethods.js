/*
$(document).ready(function () {
    $.ajax({
        url: 'https://localhost:44300/api/task',
        type: "GET",
        success: function (data) {
            $.each(data, function (key, item) {
              //  $('<li>', { text: formatItem(item) }).appendTo($('#tasks'));
            });
        }
    });
});

function formatItem(item) {
    return item.Id + '. ' + item.Name;
}

function add() {
    var name = $('#name').val();
    var id = $('#addId').val();
    $.ajax({
        url: 'https://localhost:44300/api/task',
        type: "PUT",
        data: { id: id, name: name },
        success: function (data) {
            alert("Added successfully");
        }
    });
}

$("#deleteApi").click(function () {
    var id = $("#userId").val();
    $.ajax({
        url: "https://localhost:44300/api/task/" + id,
        type: "DELETE",
        data: data,
        success: function (data) {
            alert("Deleted successfully");
        }
    });
});

function edit() {
    var id = $("#editId").val();
    var name = $("#editName").val();
    $.ajax({
        url: "https://localhost:44300/api/task/",
        type: "POST",
        data: { id: id, name: name },
        success: function (data) {
            alert("Edited successfully");
        }
    });
}
function find() {
    var id = $('#userId').val();
    $.getJSON('api/task' + '/' + id)
        .done(function (data) {
            $('#task').text(formatItem(data));
        })
        .fail(function (jqXHR, textStatus, err) {
            $('#task').text('Error: ' + err);
        });
}
*/