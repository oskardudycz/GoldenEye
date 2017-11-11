function UserService() {

    var self = this;

    function handleLogOut() {
        toastr.error("Zostałeś wylogowany!", "Błąd");
        cache.ClearAll();
        routing.refresh();
    }

    function handleStandardError(jqXHR, exception) {
        if (jqXHR.status === 401) {
            handleLogOut();
            return true;
        }
        return false;
    }

    self.getUser = function (username, callback) {
        $.ajax({
            url: "/api/user?$filter=(UserName eq '" + username  + "')",
            dataType: "json",
            contentType: "application/json; charset=utf-8",
            type: "GET",
            headers: {
                'Authorization': "Bearer " + authManager.getToken()
            },
            success: function(data) {
                callback(data[0]);
            },
            error: handleStandardError
        });
    }
};

var userService = new UserService();