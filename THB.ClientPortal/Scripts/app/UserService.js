function UserService() {

    var self = this;

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
            }
        });
    }
};

var userService = new UserService();