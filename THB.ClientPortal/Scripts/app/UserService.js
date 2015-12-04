function UserService() {

    var self = this;

    self.getUser = function (callback) {
        $.ajax({
            url: '/api/user/1',
            dataType: "json",
            contentType: 'application/json; charset=utf-8',
            type: "GET",
            data: { get_param: 'value' },
            headers: {
                'Authorization': "Bearer " + authManager.getToken()
            },
            success: function (data) {
                callback(data);
            }
        })
    }
};

var userService = new UserService();